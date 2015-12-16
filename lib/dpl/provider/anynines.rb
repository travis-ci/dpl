module DPL
  class Provider
    class Anynines < CloudFoundry

      def check_auth
        initial_go_tools_install
        context.shell "./cf api https://api.de.a9s.eu"
        context.shell "./cf login --u #{option(:username)} --p #{option(:password)} --o #{option(:organization)} --s #{option(:space)}"
      end

    end
  end
end
