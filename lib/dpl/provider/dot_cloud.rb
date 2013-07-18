module DPL
  class Provider
    class DotCloud < Provider
      experimental "dotCloud"
      pip 'dotcloud'

      def check_auth
        context.shell "echo #{option(:api_key)} | dotcloud setup --api-key"
      end

      def check_app
        `dotcloud connect #{option(:app)}`
      end

      def needs_key?
        false
      end

      def push_app
        `dotcloud push #{option(:app)}`
      end

      def run(command)
        service = options[:instance] || options[:service] || 'www'
        `dotcloud -A #{option(:app)} #{service} #{command}`
      end
    end
  end
end