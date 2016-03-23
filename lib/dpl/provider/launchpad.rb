require 'net/http'
require 'net/https'

module DPL
  class Provider
    class Launchpad < Provider

      def check_auth
      end

      def needs_key?
        false
      end

      def push_app
        http = Net::HTTP.new('api.launchpad.net', 443)
        http.use_ssl = true
        req = Net::HTTP::Post.new("/1.0/" + options[:slug] + "/+code-import")
        req.set_form_data('ws.op' => 'requestImport')
        req['Authorization'] =
          'OAuth oauth_consumer_key="Travis%20Deploy", ' +
          'oauth_nonce="' + rand(36**32).to_s(36) + '",' +
          'oauth_signature="%26' + options[:oauth_token_secret] + '",' +
          'oauth_signature_method="PLAINTEXT",' +
          'oauth_timestamp="' + Time::now().to_i.to_s + '",' +
          'oauth_token="' + options[:oauth_token] + '",' +
          'oauth_version="1.0"'
        response = http.request(req)
        error('Deploy failed! Response Code: ' + response.code.to_s) if response.code != '200'
      end
    end
  end
end
