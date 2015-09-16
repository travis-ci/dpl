require 'open3'

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
        stdin, stdout, stderr, wait_thr = Open3.popen3(script)
        while wait_thr.status do
          sleep 1
        end

        log stdout.read
        warn stderr.read

        status = wait_thr.value
        if !status.success?
          raise Error, "Script #{File.join(ENV['PWD'], script)} failed with status #{status.exitstatus}"
        end
      end

      def script
        options[:script]
      end
    end
  end
end
