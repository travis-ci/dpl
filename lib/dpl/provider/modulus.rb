module DPL
  class Provider
    class Modulus < Provider
      npm_g 'modulus'

      def check_auth
        raise Error, "must supply an api key" unless option(:api_key)
      end

      def check_app
        raise Error, "must supply a project name" unless option(:project_name)
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "env MODULUS_TOKEN=#{option(:api_key)} modulus deploy -p #{option(:project_name)}"
      end
    end
  end
end
