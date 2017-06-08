require 'pathname'

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
        scriptPath = Pathname.new(script)
        if not scriptPath.file?
          raise Error, "The script file #{scriptPath} (#{scriptPath.expand_path}) does not exist"
        end
        if not scriptPath.executable?
          raise Error, "The script file #{scriptPath} isn't executable"
        end
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
