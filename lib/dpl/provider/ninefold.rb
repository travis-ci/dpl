module DPL
  class Provider
    class Ninefold < Provider
      requires 'ninefold'

      def check_auth
        raise Error, "must supply an auth token" unless option(:auth_token)
      end

      def check_app
        raise Error, "must supply an app ID" unless option(:app_id)
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "AUTH_TOKEN=#{option(:auth_token)} APP_ID=#{option(:app_id)} ninefold app redeploy --sure"
      end
    end
  end
end
