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
        log "Logged in as #{user.name}"
      end

      def push_app
        tag_matched = false
        release_url = nil

        releases.each do |release|
          if release.tag_name == get_tag
            release_url = release.rels[:self].href
            tag_matched = true
          end
        end

        #If for some reason GitHub hasn't already created a release for the tag, create one
        if tag_matched == false
          release_url = api.create_release(slug, get_tag).rels[:self].href
        end

        Array(options[:file]).each do |file|
          api.upload_asset(release_url, Pathname.new(file).basename.to_s, {:content_type => MIME::Types.type_for(file).first.to_s})
        end
      end
    end
  end
end
