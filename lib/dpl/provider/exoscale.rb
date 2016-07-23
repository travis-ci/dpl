require 'json'
require 'net/http'
require 'net/https'

module DPL
  class Provider
    class ExoScale < CloudControl
      def initialize(context, options)
        super
        @http = Net::HTTP.new('api.app.exo.io', 443)
        @http.use_ssl = true

        @tokenHttp = Net::HTTP.new('portal.exoscale.ch', 443)
        @tokenHttp.use_ssl = true
      end
    private
      def get_token
        request = Net::HTTP::Post.new '/api/apps/token'
        request.basic_auth options[:email], options[:password]
        response = @tokenHttp.request(request)
        error('authorization failed') if response.code != '200'
        return JSON.parse response.body
      end
    end
  end
end
