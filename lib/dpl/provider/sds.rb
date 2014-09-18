require 'json'

module DPL
  class Provider
    class SDS < Provider
      requires 'aws-sdk'

      def needs_key?
        false
      end

      def push_app
      end
    end
  end
end
