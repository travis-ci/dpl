module DPL
  class Provider
    class Openshift < Provider
      requires 'rhc'

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
        context.shell "git push #{app.git_url} -f"
      end

      def restart
        app.restart
      end

    end
  end
end
