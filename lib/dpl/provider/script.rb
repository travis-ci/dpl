module DPL
  class Provider
    class Script < Provider

      experimental 'Script'

      def check_auth
      end

      def check_app
      end

      def needs_key?
        false
      end

      def push_app
        context.shell script
        if $?.exitstatus != 0
          raise Error, "Script failed with status #{$?.exitstatus}"
        end
      end

      def script
        options[:script]
      end
    end
  end
end
