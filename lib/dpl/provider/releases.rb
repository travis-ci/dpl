module DPL
  class Provider
    class Releases < Provider
      require 'pathname'

      requires 'octokit'
      requires 'mime-types'

      def get_tag 
        `git describe --tags --exact-match 2>/dev/null`.chomp
      end

      def api
        if options[:user] and options[:password]
          @api ||= Octokit::Client.new(:login => options[:user], :password => options[:password])
        else
          @api ||= Octokit::Client.new(:access_token => option(:api_key))
        end
      end

      def slug
        options.fetch(:repo) { ENV['TRAVIS_REPO_SLUG'] }
      end

      def releases
        @releases ||= api.releases(slug)
      end

      def user
        user ||= api.user
      end

      def needs_key?
        false
      end

      def check_app
        log "Deploying to repo: #{slug}"
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
          release_url = api.create_release(slug, get_tag).rels[:self].href
        end

        Array(options[:file]).each do |file|
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
            api.upload_asset(release_url, file, {:name => filename, :content_type => MIME::Types.type_for(file).first.to_s})
          end
        end
      end
    end
  end
end
