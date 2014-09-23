require 'json'

module DPL
  class Provider
    class SDS < S3
      def push_app
        super
      end
    end
  end
end
