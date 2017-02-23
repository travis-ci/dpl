require 'net/http'
require 'net/https'

module DPL
  class Provider
    class Launchpad < Provider

      def initialize(context, options)
        super
        @http = Net::HTTP.new('api.launchpad.net', 443)
        @http.use_ssl = true
      end

      def check_auth
      end

      def needs_key?
        false
      end

      def push_app
        response = api_call('/1.0/' + options[:slug] + '/+code-import', {'ws.op' => 'requestImport'})
        error('Deploy failed! Launchpad credentials invalid. ' + response.code.to_s) if response.code == '401'
        error('Error: ' + response.code.to_s + ' ' + response.body) unless response.kind_of? Net::HTTPSuccess
      end

      private

        def api_call(path, data)
          req = Net::HTTP::Post.new(path)
          req.set_form_data(data)
          req['Authorization'] = authorization
          return @http.request(req)
        end

        def authorization
          return 'OAuth oauth_consumer_key="Travis%20Deploy", ' +
                 'oauth_nonce="' + rand(36**32).to_s(36) + '",' +
                 'oauth_signature="%26' + options[:oauth_token_secret] + '",' +
                 'oauth_signature_method="PLAINTEXT",' +
                 'oauth_timestamp="' + Time::now().to_i.to_s + '",' +
                 'oauth_token="' + options[:oauth_token] + '",' +
                 'oauth_version="1.0"'
        end

    end
  end
end
