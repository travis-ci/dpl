# frozen_string_literal: true

module Dpl
  module Providers
    class Hackage < Provider
      register :hackage

      status :alpha

      description sq(<<-STR)
        tbd
      STR

      env :hackage

      opt '--username USER', 'Hackage username', required: true
      opt '--password USER', 'Hackage password', required: true, secret: true
      opt '--publish', 'Whether or not to publish the package'

      cmds check: 'cabal check',
           sdist: 'cabal sdist',
           upload: 'cabal upload %{upload_opts} %{path}'

      errs check: 'cabal check failed',
           sdist: 'cabal sdist failed',
           upload: 'cabal upload failed'

      def validate
        shell :check
      end

      def prepare
        shell :sdist
      end

      def deploy
        tar_files.each do |path|
          shell :upload, path:
        end
      end

      private

      def upload_opts
        opts_for(%i[publish username password])
      end

      def tar_files
        Dir.glob('dist/*.tar.gz').sort
      end
    end
  end
end
