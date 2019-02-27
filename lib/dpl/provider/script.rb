module DPL
  class Provider
    class Script < Provider
      def self.new(context, options)
        super(context, options.merge!({needs_git_http_user_agent: false}))
      end

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
