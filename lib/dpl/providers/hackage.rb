module Dpl
  module Providers
    class Hackage < Provider
      summary 'Hackage deployment provider'

      description <<~str
        tbd
      str

      apt 'cabal', 'cabal-install'

      opt '--username USER', 'Hackage username', required: true
      opt '--password USER', 'Hackage password', required: true

      cmds validate: 'cabal check',
           prepare:  'cabal dist',
           upload:   'cabal upload %s %s'

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
        Dir.glob('dist/*.tar.gz') do |tar|
          shell :upload, opts_for(%i(username password)), tar, assert: true
        end
      end
    end
  end
end
