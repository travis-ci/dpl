# frozen_string_literal: true

module Dpl
  module Providers
    class Boxfuse < Provider
      register :boxfuse

      status :alpha

      description sq(<<-STR)
        tbd
      STR

      env :boxfuse

      opt '--user USER', required: true
      opt '--secret SECRET', required: true, secret: true
      opt '--payload PAYLOAD'
      opt '--app APP'
      opt '--version VERSION'
      opt '--env ENV'
      opt '--config_file FILE', alias: :configfile, deprecated: :configfile
      opt '--extra_args ARGS'

      URL = 'https://files.boxfuse.com/com/boxfuse/client/boxfuse-commandline/1.33.0.1460/boxfuse-commandline-1.33.0.1460-linux-x64.tar.gz'

      cmds install: 'curl -L %{URL} | tar xz',
           deploy: 'boxfuse/boxfuse run %{deploy_opts}'

      def validate
        # TODO: check if the config file exists (it seems `boxfuse` doesn't)
      end

      def install
        shell :install
      end

      def deploy
        shell :deploy
      end

      private

      def deploy_opts
        opts = [*opts_for(%i[user secret payload app env version], prefix: '-')]
        opts << "-configfile=#{config_file}" if config_file?
        opts << extra_args if extra_args?
        opts.join(' ')
      end
    end
  end
end
