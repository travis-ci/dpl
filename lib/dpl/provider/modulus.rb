module DPL
  class Provider
    class Modulus < Provider
      npm_g 'modulus'

      def check_auth
      end

      def check_app
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "MODULUS_TOKEN=#{option(:api_key)} modulus deploy -p #{option(:project_name)}"
      end
    end
  end
end
