module DPL
  class Provider
    class Releases < Provider
      require 'pathname'

      requires 'octokit'
      requires 'mime-types', version: '~> 2.0'

      def travis_tag
        # Check if $TRAVIS_TAG is unset or set but empty
        if context.env.fetch('TRAVIS_TAG','') == ''
          nil
        else
          context.env['TRAVIS_TAG']
        end
      end

      def get_tag
        if travis_tag.nil?
          @tag ||= `git describe --tags --exact-match 2>/dev/null`.chomp
        else
          @tag ||= travis_tag
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

        context.shell 'git fetch --tags' if travis_tag.nil?
        log "Current tag is: #{get_tag}"
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

        if options[:release_number]
          tag_matched = true
          release_url = "https://api.github.com/repos/" + slug + "/releases/" + options[:release_number]
        else
          releases.each do |release|
            if release.tag_name == get_tag
              release_url = release.rels[:self].href
              tag_matched = true
            end
          end
        end

        #If for some reason GitHub hasn't already created a release for the tag, create one
        if tag_matched == false
          release_url = api.create_release(slug, get_tag, options).rels[:self].href
        end

        files.each do |file|
          already_exists = false
          filename = Pathname.new(file).basename.to_s
          api.release(release_url).rels[:assets].get.data.each do |existing_file|
            if existing_file.name == filename
              already_exists = true
            end
          end
          if already_exists
            log "#{filename} already exists, skipping."
          else
            content_type = MIME::Types.type_for(file).first.to_s
            if content_type.empty?
              # Specify the default content type, as it is required by GitHub
              content_type = "application/octet-stream"
            end
            api.upload_asset(release_url, file, {:name => filename, :content_type => content_type})
          end
        end
      end
    end
  end
end
