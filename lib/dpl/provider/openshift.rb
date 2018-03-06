require 'httpclient'
require 'net/ssh'
require 'net/ssh/gateway'

module DPL
  class Provider
    class Openshift < Provider
      def initialize(context, options)
        super
        @deployment_branch = options[:deployment_branch]
      end

      def api
        @api ||= ::RHC::Rest::Client.new(:user => option(:user), :password => option(:password), :server => 'openshift.redhat.com')
      end

      def user
        @user ||= api.user.login
      end

      def app
        @app ||= api.find_application(option(:domain), option(:app))
      end

      def check_auth
        log "authenticated as %s" % user
      end

      def check_app
        log "found app #{app.name}"
      end

      def setup_key(file, type = nil)
        specified_type, content, comment = File.read(file).split
        api.add_key(option(:key_name), content, type || specified_type)
      end

      def remove_key
        api.delete_key(option(:key_name))
      end

      def push_app
        if @deployment_branch
          log "deployment_branch detected: #{@deployment_branch}"
          app.deployment_branch = @deployment_branch
          context.shell "git push #{app.git_url} -f #{app.deployment_branch}"
        else
          context.shell "git push #{app.git_url} -f"
        end
      end

      def restart
        app.restart
      end

    end
  end
end
