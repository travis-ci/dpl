module Dpl
  module Providers
    class Releases < Provider
      status :alpha

      full_name 'GitHub Releases'

      description sq(<<-str)
        tbd
      str

      gem 'octokit', '~> 4.14.0'
      gem 'mime-types', '~> 3.2.2'
      gem 'public_suffix', '~> 3.0.3'

      required :api_key, [:user, :password]

      opt '--api_key TOKEN', 'GitHub oauth token (needs public_repo or repo permission)', secret: true
      opt '--username LOGIN', 'GitHub login name', alias: :user
      opt '--password PASS', 'GitHub password', secret: true
      opt '--repo SLUG', 'GitHub repo slug', default: :repo_slug
      opt '--file FILE', 'File to release to GitHub', required: true, type: :array
      opt '--file_glob', 'Interpret files as globs'
      opt '--overwrite', 'Overwrite files with the same name'
      opt '--prerelease', 'Identify the release as a prerelease'
      opt '--release_number NUM', 'Release number (overide automatic release detection)'
      # from octokit
      opt '--draft', 'Identify the release as a draft'
      opt '--tag_name TAG', 'Git tag from which to create the release'
      opt '--target_commitish STR', 'Commitish value that determines where the Git tag is created from'
      opt '--name NAME', 'Name for the release'
      opt '--body BODY', 'Content for the release notes'
      # should this have --github_url, like Pages does?

      needs :git

      msgs deploy:               'Deploying to repo: %{slug}',
           local_tag:            'Current tag is: %{local_tag}',
           login:                'Logged in as %s',
           insufficient_scopes:  'Dpl does not have permission to upload assets. Make sure your token has the repo or public_repo scope.',
           overwrite_existing:   'File %s already exists, overwriting.',
           skip_existing:        'File %s already exists, skipping.',
           set_tag_name:         'Setting tag_name to %s',
           set_target_commitish: 'Setting target_commitish to %s',
           missing_file:         '%s does not exist.',
           not_a_file:           '%s is not a file, skipping.'

      URL = 'https://api.github.com/repos/%s/releases/%s'

      OCTOKIT_OPTS = %i(
        repo
        name
        body
        prerelease
        release_number
        tag_name
        target_commitish
      )

      TIMEOUTS = {
        timeout: 180,
        open_timeout: 180
      }

      def validate
        info :deploy
        # might not have a git remote set up
        shell 'git fetch --tags' if env_tag.nil?
        # error if local_tag is nil?
        info :local_tag
      end

      def login
        user.login
        error :insufficient_scopes unless sufficient_scopes?
        info :login, user.name
      end

      def deploy
        upload_files
        opts = with_tag(self.opts.dup)
        opts = with_target_commitish(opts)
        api.update_release(url, filter(opts).merge(draft: draft?))
      end

      def upload_files
        files.each { |file| upload_file(file) }
      end

      def upload_file(file)
        asset = asset(file)
        return info :skip_existing, file if asset && !overwrite?
        delete(asset, file) if asset
        api.upload_asset(url, file, name: File.basename(file), content_type: content_type(file))
      end

      def delete(asset, file)
        info :overwrite_existing, file
        api.delete_release_asset(asset.url)
      end

      def with_tag(opts)
        return opts if tag_name? || draft?
        info :set_tag_name, local_tag
        opts.merge(tag_name: local_tag)
      end

      def with_target_commitish(opts)
        return opts if target_commitish? || !same_repo?
        info :set_target_commitish, git_sha
        opts.merge(target_commitish: git_sha)
      end

      def content_type(file)
        type = MIME::Types.type_for(file).first
        type ||= 'application/octet-stream'
        type.to_s
      end

      def url
        if release_number?
          URL % [slug, release_number]
        elsif release
          release.rels[:self].href
        else
          create_release.rels[:self].href
        end
      end

      def release
        releases.detect { |release| release.tag_name == local_tag }
      end

      def create_release
        api.create_release(slug, local_tag, filter(opts).merge(draft: true))
      end

      def local_tag
        env_tag || git_tag
      end

      def env_tag
        tag = ENV['TRAVIS_TAG']
        tag unless tag.to_s.empty?
      end

      def sufficient_scopes?
        api.scopes.include?('public_repo') || api.scopes.include?('repo')
      end

      def slug
        repo || repo_slug
      end

      def same_repo?
        slug == repo_slug
      end

      def asset(path)
        api.release_assets(url).detect { |asset| asset.name == path }
      end

      def user
        @user ||= api.user
      end

      def releases
        @releases ||= api.releases(slug)
      end

      def api
        @api ||= Octokit::Client.new(**creds, auto_paginate: true, connection_options: { request: TIMEOUTS })
      end

      def creds
        username && password ? { login: username, password: password } : { access_token: api_key }
      end

      def files
        files = file_glob? ? Dir.glob("{#{file.join(',')}}").uniq : file
        files = files.select { |file| exists?(file) }
        files.select { |file| file?(file) }
      end

      def filter(opts)
        opts.select { |key, _| OCTOKIT_OPTS.include?(key) }
      end

      def exists?(file)
        return true if File.exists?(file)
        warn :missing_file, file
        false
      end

      def file?(file)
        return true if File.file?(file)
        warn :not_a_file, file
        false
      end
    end
  end
end
