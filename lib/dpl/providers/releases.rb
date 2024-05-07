# frozen_string_literal: true

require 'dpl/helper/github'

module Dpl
  module Providers
    class Releases < Provider
      include Github

      register :releases

      status :stable

      full_name 'GitHub Releases'

      description sq(<<-STR)
        tbd
      STR

      gem 'octokit', '~> 7'
      gem 'mime-types', '~> 3.4.1'
      gem 'public_suffix', '~> 5'

      env :github, :releases

      required :token, %i[username password]

      opt '--token TOKEN', 'GitHub oauth token (needs public_repo or repo permission)', secret: true, alias: :api_key
      opt '--username LOGIN', 'GitHub login name', alias: :user
      opt '--password PASS', 'GitHub password', secret: true
      opt '--repo SLUG', 'GitHub repo slug', default: :repo_slug
      opt '--file GLOB', 'File or glob to release to GitHub', default: '*', type: :array
      opt '--file_glob', 'Interpret files as globs', default: true
      opt '--overwrite', 'Overwrite files with the same name'
      opt '--prerelease', 'Identify the release as a prerelease'
      opt '--release_number NUM', 'Release number (override automatic release detection)'
      opt '--release_notes STR', 'Content for the release notes', alias: :body
      opt '--release_notes_file PATH', 'Path to a file containing the release notes', note: 'will be ignored if --release_notes is given'
      opt '--draft', 'Identify the release as a draft'
      opt '--tag_name TAG', 'Git tag from which to create the release'
      opt '--target_commitish STR', 'Commitish value that determines where the Git tag is created from'
      opt '--name NAME', 'Name for the release'
      # should this have --url, like Pages does?

      needs :git

      msgs deploy: 'Deploying to repo: %{slug}',
           local_tag: 'Current tag is: %{local_tag}',
           login: 'Authenticated as %s',
           insufficient_scopes: 'Dpl does not have permission to upload assets. Make sure your token has the repo or public_repo scope.',
           insufficient_perm: 'Release resource not found. Make sure your token belongs to an account which has push permission to this repo.',
           overwrite_existing: 'File %s already exists, overwriting.',
           skip_existing: 'File %s already exists, skipping.',
           upload_file: 'Uploading file %s ...',
           set_tag_name: 'Setting tag_name to %s',
           set_target_commitish: 'Setting target_commitish to %s',
           missing_file: 'File %s does not exist.',
           not_a_file: '%s is not a file, skipping.'

      cmds git_fetch_tags:       'git fetch --tags'

      URL = 'https://api.github.com/repos/%s/releases/%s'

      OCTOKIT_OPTS = %i[
        repo
        name
        body
        prerelease
        release_number
        tag_name
        target_commitish
      ].freeze

      TIMEOUTS = {
        timeout: 180,
        open_timeout: 180
      }.freeze

      def validate
        info :deploy
        shell :git_fetch_tags if env_tag.nil?
        info :local_tag
      end

      def login
        user.login
        info :login, user.login
        error :insufficient_scopes unless sufficient_scopes?
      end

      def deploy
        upload_files
        api.update_release(url, octokit_opts)
      end

      def upload_files
        files.each { |file| upload_file(file) }
      end

      def upload_file(path)
        file = normalize_filename(path)
        asset = asset(file)
        return info :skip_existing, file if asset && !overwrite?

        delete(asset, file) if asset
        info :upload_file, file
        api.upload_asset(url, path, name: file, content_type: content_type(path))
      end

      def delete(asset, file)
        info :overwrite_existing, file
        api.delete_release_asset(asset.url)
      end

      def octokit_opts
        opts = with_tag(self.opts.dup)
        opts = with_target_commitish(opts)
        opts = opts.select { |key, _| OCTOKIT_OPTS.include?(key) }
        compact(opts.merge(body: release_notes, draft: draft?))
      end
      memoize :octokit_opts

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
          format(URL, slug, release_number)
        elsif release
          release.rels[:self].href
        else
          create_release.rels[:self].href
        end
      end
      memoize :url

      def release
        releases.detect { |release| release.tag_name == local_tag }
      end

      def create_release
        api.create_release(slug, local_tag, octokit_opts.merge(draft: true))
      rescue Octokit::NotFound
        error :insufficient_perm
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

      def asset(name)
        api.release_assets(url).detect { |asset| asset.name == name }
      end

      def release_notes
        super || release_notes_file || nil
      end

      def release_notes_file
        release_notes_file? && exists?(super) && read(super)
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
        username && password ? { login: username, password: } : { access_token: token }
      end

      def files
        files = file_glob? ? Dir.glob("{#{file.join(',')}}").uniq : file
        files = files.select { |file| exists?(file) }
        files.select { |file| file?(file) }
      end

      def exists?(file)
        return true if File.exist?(file)

        error :missing_file, file
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
