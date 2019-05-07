module Dpl
  module Providers
    class Snap < Provider
      summary 'Snap deployment provider'

      apt 'snapd', 'snap'

      description <<~str
        tbd
      str

      env :snap

      opt '--snap STR', 'Path to the snap to be pushed (can be a glob)', required: true
      opt '--channel CHAN', 'Channel into which the snap will be released', default: 'edge'
      opt '--token TOKEN', 'Snap API token', required: true

      CMDS = {
        login:   'snapcraft login --with %{token}',
        install: 'sudo snap install snapcraft --classic',
        deploy:  'snapcraft push %s --release=%s'
      }

      MSGS = {
        login:          'Attemping to login ...',
        no_snaps:       'No snap found matching %{snap}',
        multiple_snaps: 'Multiple snaps found matching %s: %s'
      }

      def install
        install_snapcraft unless which 'snapcraft'
      end

      def login
        info :login
        shell :login, assert: 'Failed to authenticate: %{err}', info: '%{out}'
      end

      def validate
        error :no_snaps if snaps.empty?
        error :multiple_snaps, snap, snaps.join(', ') if snaps.size > 1
      end

      def deploy
        shell :deploy, snaps.first, channel
      end
      # fold 'Pushing snap'

      def snaps
        @snaps ||= Dir[snap].sort
      end

      def install_snapcraft
        shell :install
        ENV['PATH'] += ':/snap/bin'
      end
    end
  end
end
