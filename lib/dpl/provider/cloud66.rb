require 'net/http'
require 'net/https'

module DPL
  class Provider
    class Cloud66 < Provider
      def needs_key?
        false
      end

      def push_app
        uri = URI.parse(redeployment_hook)

        response = webhook_call(uri.scheme, uri.host, uri.port, uri.path)

        error("Redeployment failed [#{response.code}]") if response.code != '200'
      end

      def check_auth
      end

      private

      def webhook_call(scheme, host, port, path)
        http = Net::HTTP.new(host, port)
        http.use_ssl = (scheme.downcase == 'https')

        request = Net::HTTP::Post.new(path)

        return http.request(request)
      end

      def redeployment_hook
        option(:redeployment_hook)
      end
    end
  end
end