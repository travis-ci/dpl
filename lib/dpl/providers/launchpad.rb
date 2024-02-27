# frozen_string_literal: true

module Dpl
  module Providers
    class Launchpad < Provider
      register :launchpad

      status :alpha

      description sq(<<-STR)
        tbd
      STR

      env :launchpad

      opt '--oauth_token TOKEN', 'Launchpad OAuth token', secret: true
      opt '--oauth_token_secret SECRET', 'Launchpad OAuth token secret', secret: true
      opt '--slug SLUG', 'Launchpad project slug', format: %r{^~[^/]+/[^/]+/[^/]+$}, example: '~user-name/project-name/branch-name'

      msgs invalid_credentials: 'Invalid credentials (%s)',
           unknown_error: 'Error: %s (%s)'

      def deploy
        handle_response(post)
      end

      private

      def post
        req = Net::HTTP::Post.new(path)
        req['Authorization'] = authorization
        req.set_form_data(data)
        http.request(req)
      end

      def handle_response(res)
        error :invalid_credentials, res.code if res.code == '401'
        error :unknown_error, res.body, res.code unless res.is_a?(Net::HTTPSuccess)
      end

      def http
        http = Net::HTTP.new('api.launchpad.net', 443)
        http.use_ssl = true
        http
      end

      def path
        "/1.0/#{slug}/+code-import"
      end

      def data
        { 'ws.op' => 'requestImport' }
      end

      def authorization
        squish(<<-AUTH)
            OAuth oauth_consumer_key="Travis%20Deploy",
            oauth_nonce="#{nonce}",
            oauth_signature="%26#{oauth_token_secret}",
            oauth_signature_method="PLAINTEXT",
            oauth_timestamp="#{now}",
            oauth_token="#{oauth_token}",
            oauth_version="1.0"
        AUTH
      end

      def nonce
        rand(36**32).to_s(36)
      end

      def now
        Time.now.to_i
      end

      def squish(str)
        str.strip.gsub(/\s+/, ' ')
      end
    end
  end
end
