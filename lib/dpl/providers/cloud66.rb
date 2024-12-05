# frozen_string_literal: true

module Dpl
  module Providers
    class Cloud66 < Provider
      register :cloud66

      status :alpha

      description sq(<<-STR)
        tbd
      STR

      env :cloud66

      opt '--redeployment_hook URL', 'The redeployment hook URL', required: true, secret: true

      msgs failed: 'Redeployment failed (%s)'

      def deploy
        response = client.request(request)
        error :failed, response.code if response.code != '200'
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

      def uri
        @uri ||= URI.parse(redeployment_hook)
      end

      def use_ssl?
        uri.scheme.downcase == 'https'
      end
    end
  end
end
