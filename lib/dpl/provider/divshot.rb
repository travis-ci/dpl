module DPL
  class Provider
    class Divshot < Provider
      npm_g 'divshot-cli', 'divshot'

      def check_auth
        raise Error, "must supply an api key" unless option(:api_key)
      end

      def check_app
        error "missing divshot.json" unless File.exist? "divshot.json"
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "divshot push #{options[:environment] || "production"} --token #{option(:api_key)}"
      end
    end
  end
end