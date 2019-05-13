module Dpl
  module Providers
    class Cloud66 < Provider
      summary 'Cloud66 deployment provider'

      description <<~str
        tbd
      str

      opt '--redeployment_hook URL', 'The redeployment hook URL', required: true

      msgs failed: 'Redeployment failed (%s)'

      def deploy
        response = client.request(request)
        error(response) if response.code != '200'
      end

      private

        def client
          Net::HTTP.new(uri.host, uri.port).tap do |client|
            client.use_ssl = use_ssl?
          end
        end

        def request
          Net::HTTP::Post.new(uri.path)
        end

        def use_ssl?
          uri.scheme.downcase == 'https'
        end

        def uri
          @uri ||= URI.parse(redeployment_hook)
        end

        def error(response)
          super(:failed, response.code)
        end
    end
  end
end
