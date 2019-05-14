module Dpl
  module Providers
    class Boxfuse < Provider
      description sq(<<-str)
        BitBallon does something.
      str

      opt '--user USER'
      opt '--secret SECRET'
      opt '--config_file FILE', alias: :configfile, deprecated: :configfile
      opt '--payload PAYLOAD'
      opt '--image IMAGE'
      opt '--env ENV'
      opt '--args ARGS', alias: :extra_args, deprecated: :extra_args

      URL = 'https://files.boxfuse.com/com/boxfuse/client/boxfuse-commandline/latest/boxfuse-commandline-latest-linux-x64.tar.gz'

      def install
        shell "curl -L #{URL} | tar xz"
      end

      def deploy
        shell deploy_cmd
      end

      private

        def deploy_cmd
          opts = %i(user secret payload image env)
          cmd = ['boxfuse/boxfuse run', *opts_for(opts)]
          cmd << "--configfile=#{config_file}" if config_file?
          cmd << args if args?
          cmd.compact.join(' ')
        end
    end
  end
end
