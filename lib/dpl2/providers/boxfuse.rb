require 'dpl2/provider'

module Dpl
  module Providers
    class Boxfuse < Provider
      summary 'Boxfuse deployment provider'

      description <<~str
        BitBallon does something.
      str

      opt '--user USER'
      opt '--secret SECRET'
      opt '--config_file FILE', deprecated: '--configfile'
      opt '--configfile FILE' # move this to Cl?
      opt '--payload PAYLOAD'
      opt '--image IMAGE'
      opt '--env ENV'
      opt '--args ARGS', deprecated: '--extra_args'
      opt '--extra_args ARGS' # move this to Cl?

      URL = 'https://files.boxfuse.com/com/boxfuse/client/boxfuse-commandline/latest/boxfuse-commandline-latest-linux-x64.tar.gz'

      def install
        shell "curl -L #{URL} | tar xz"
      end

      def cmd
        opts = %i(user secret payload image env)
        cmd = ['boxfuse/boxfuse run', *opts_for(opts)]
        cmd << "--configfile=#{config_file}" if config_file?
        cmd << args if args? || extra_args?
        cmd.compact.join(' ')
      end

      def config_file?
        opts.key?(:config_file) || opts.key?(:configfile)
      end

      def config_file
        opts[:config_file] || deprectated_opt(:configfile, :config_file)
      end

      def args
        opts[:args] || deprectated_opt(:extra_args, :args)
      end
    end
  end
end
