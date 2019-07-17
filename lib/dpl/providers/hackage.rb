module Dpl
  module Providers
    class Hackage < Provider
      description sq(<<-str)
        tbd
      str

      # does not seem to be necessary?
      # apt 'cabal-install'

      opt '--username USER', 'Hackage username', required: true
      opt '--password USER', 'Hackage password', required: true

      cmds check:  'cabal check',
           sdist:  'cabal sdist',
           upload: 'cabal upload %{upload_opts} %{path}'

      errs check:  'cabal check failed',
           sdist:  'cabal sdist failed',
           upload: 'cabal upload failed'

      def validate
        shell :check, echo: true, assert: true
      end

      def prepare
        shell :sdist, echo: true, assert: true
      end

      def deploy
        tar_files.each do |path|
          shell :upload, path: path, assert: true
        end
      end

      private

        def upload_opts
          opts_for(%i(username password))
        end

        def tar_files
          Dir.glob('dist/*.tar.gz').sort
        end
    end
  end
end
