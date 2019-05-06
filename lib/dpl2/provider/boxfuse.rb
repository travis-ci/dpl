require 'dpl2/provider/base'

module Dpl
  module Provider
    class Boxfuse < Base
      INSTALL = 'curl -L https://files.boxfuse.com/com/boxfuse/client/boxfuse-commandline/latest/boxfuse-commandline-latest-linux-x64.tar.gz | tar xz'

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

      def prepare
        shell INSTALL
      end

      def cmd
        opts = %i(user secret payload image env)
        cmd = ['boxfuse/boxfuse run', *to_opts(opts)]
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
