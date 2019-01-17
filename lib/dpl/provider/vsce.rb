require 'json'
require 'uri'

module DPL
  class Provider
    class VSCE < Provider
      npm_g 'vsce'

      def needs_key?
        false
      end

      def check_auth
        option(:token)
      end

      def package_app
        if ! context.shell "vsce package"
            raise Error, "Packaging failed"
        end
      end

      def push_app
        package_app

        if ! context.shell "vsce publish --pat #{option(:token)}"
            raise Error, "Publish failed"
        end
      end
    end
  end
end
