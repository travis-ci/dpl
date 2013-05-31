module DPL
  class Provider
    class DotCloud < Provider
      pip 'dotcloud'

      def check_auth
        system "echo #{option(:api_key)} | dotcloud setup --api-key"
      end

      def needs_key?
        false
      end

      def push_app
        `dotcloud push #{option(:app)}`
      end

      def run(command)
        service = option[:instance] || option[:service] || 'www'
        `dotcloud -A #{option(:app)} #{service} #{command}`
      end
    end
  end
end