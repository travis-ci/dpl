require 'json'
require 'uri'

module DPL
  class Provider
    class Cargo < Provider
      def needs_key?
        false
      end

      def check_auth
        option(:token)
      end

      def push_app
        if ! context.shell "cargo publish --token #{option(:token)}"
          raise Error, "Publish failed"
        end
      end
    end
  end
end
