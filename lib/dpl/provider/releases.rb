require 'octokit'
require 'mime-types'

module DPL
  class Provider
    class Releases < Provider
      require 'pathname'

      BOOLEAN_PARAMS = %w(
        draft
        prerelease
      )

      attr_reader :current_tag

      def current_tag
        return @current_tag if @current_tag

        log "Determining tag for this GitHub Release"

        @tag = tag_name(options[:tag_name])

        if @tag.empty?
          log yellow("Unable to compute tag name. GitHub may assign a tag of the form 'untagged-*'.")
        end
      end

      def tag_name(opts_tag_name)
        if opts_tag_name
          opts_tag_name.tap {|tag| log green("Tag #{tag} set in .travis.yml")}
        elsif !context.env['TRAVIS_TAG'].to_s.empty?
          context.env['TRAVIS_TAG'].to_s.tap {|tag| log green("Tag #{tag} set by TRAVIS_TAG (via this commit's tag)")}
        else
          log yellow("This commit is not tagged. Fetching tags")
          context.shell "git fetch --tags"
          `git describe --tags --exact-match 2>/dev/null`.chomp.tap do |tag|
            if tag.empty?
              log yellow("No tag is attached to this commit")
            else
              log green("Tag #{tag} is attached to this commit")
            end
          end
        end
      end

      def api
        if options[:user] and options[:password]
          @api ||= Octokit::Client.new(:login => options[:user], :password => options[:password])
        else
          @api ||= Octokit::Client.new(:access_token => option(:api_key))
        end
      end

      def slug
        options.fetch(:repo) { context.env['TRAVIS_REPO_SLUG'] }
      end

      def releases
        @releases ||= api.releases(slug)
      end

      def user
        @user ||= api.user
      end

      def files
        if options[:file_glob]
          Array(options[:file]).map do |glob|
            Dir.glob(glob)
          end.flatten
        else
          Array(options[:file])
        end
      end

      def needs_key?
        false
      end

      def check_app
        log "Deploying to repo: #{slug}"

        log "Current tag is: #{current_tag}" unless current_tag.empty?
      end

      def setup_auth
        user.login
      end

      def check_auth
        setup_auth

        unless api.scopes.include? 'public_repo' or api.scopes.include? 'repo'
          raise Error, "Dpl does not have permission to upload assets. Make sure your token contains the repo or public_repo scope."
        end

        log "Logged in as #{user.name}"
      end

      def push_app
        tag_matched = false
        release_url = nil

        booleanize!(options)

        if options[:release_number]
          tag_matched = true
          release_url = "https://api.github.com/repos/" + slug + "/releases/" + options[:release_number]
        else
          releases.each do |release|
            if release.tag_name == current_tag
              release_url = release.rels[:self].href
              tag_matched = true
            end
          end
        end

        #If for some reason GitHub hasn't already created a release for the tag, create one
        if tag_matched == false
          release_url = api.create_release(slug, current_tag, options.merge({:draft => true})).rels[:self].href
        end

        files.each do |file|
          next unless File.file?(file)
          existing_url = nil
          filename = Pathname.new(file).basename.to_s
          api.release(release_url).rels[:assets].get.data.each do |existing_file|
            if existing_file.name == filename
              existing_url = existing_file.url
            end
          end
          if !existing_url
            upload_file(file, filename, release_url)
          elsif existing_url && options[:overwrite]
            log "#{filename} already exists, overwriting."
            api.delete_release_asset(existing_url)
            upload_file(file, filename, release_url)
          else
            log "#{filename} already exists, skipping."
          end
        end

        api.update_release(release_url, {:draft => false}.merge(options))
      end

      def upload_file(file, filename, release_url)
        content_type = MIME::Types.type_for(file).first.to_s
        if content_type.empty?
          # Specify the default content type, as it is required by GitHub
          content_type = "application/octet-stream"
        end
        api.upload_asset(release_url, file, {:name => filename, :content_type => content_type})
      end

      def booleanize!(opts)
        opts.map do |k,v|
          opts[k] = if BOOLEAN_PARAMS.include?(k.to_s.squeeze.downcase)
            case v.to_s.downcase
            when 'true'
              true
            when 'false'
              false
            else
              v
            end
          else
            v
          end
        end
      end
    end
  end
end
