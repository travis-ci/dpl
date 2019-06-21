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
      opt '--extra_args ARGS'

      URL = 'https://files.boxfuse.com/com/boxfuse/client/boxfuse-commandline/latest/boxfuse-commandline-latest-linux-x64.tar.gz'

      cmds install: 'curl -L %{URL} | tar xz',
           deploy:  'boxfuse/boxfuse run %{deploy_opts}'

      def install
        shell :install
      end

      def deploy
        shell :deploy
      end

      private

        def deploy_opts
          opts = [*opts_for(%i(user secret payload image env))]
          opts << "--configfile=#{config_file}" if config_file?
          opts << extra_args if extra_args?
          opts.join(' ')
        end
    end
  end
end
