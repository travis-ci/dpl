module Dpl
  module Providers
    class Hackage < Provider
      description sq(<<-str)
        tbd
      str

      apt 'cabal-install' #, 'cabal-install'

      opt '--username USER', 'Hackage username', required: true
      opt '--password USER', 'Hackage password', required: true

      cmds validate: 'cabal check',
           prepare:  'cabal dist',
           upload:   'cabal upload %{upload_opts} %{path}'

      errs validate: 'cabal check failed',
           prepare:  'cabal dist failed',
           upload:   'cabal upload failed'

      def validate
        shell 'cabal check', assert: 'cabal check failed'
      end

      def prepare
        shell 'cabal sdist', assert: 'cabal sdist failed'
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
