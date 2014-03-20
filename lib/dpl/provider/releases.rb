module DPL
  class Provider
    class Releases < Provider
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

        releases.each do |release|
          if release.tag_name == get_tag
            api.upload_asset(release.rels[:self].href, option(:file), {:content_type => MIME::Types.type_for(option(:file)).first.to_s})
            tag_matched = true
          end
        end
        unless tag_matched
          log <<-EOS
                 This isn't a GitHub release, so nothing has been deployed. If you haven't already, please add the following to the 'deploy' section of your .travis.yml:

                 on:
                   tags: true
                   all_branches: true
                EOS
        end
      end
    end
  end
end