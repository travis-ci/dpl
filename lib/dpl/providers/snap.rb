module Dpl
  module Providers
    class Snap < Provider
      description sq(<<-str)
        tbd
      str

      env :snap

      opt '--snap STR', 'Path to the snap to be pushed (can be a glob)', required: true
      opt '--channel CHAN', 'Channel into which the snap will be released', default: 'edge'
      opt '--token TOKEN', 'Snap API token', required: true

      apt 'snapd', 'snap'

      cmds login:          'snapcraft login --with %{token}',
           install:        'sudo snap install snapcraft --classic',
           deploy:         'snapcraft push %s --release=%s'

      msgs login:          'Attemping to login ...',
           no_snaps:       'No snap found matching %{snap}',
           multiple_snaps: 'Multiple snaps found matching %{snap}: %{snap_paths}',
           deploy:         'Pushing snap %{snap_path}'

      def install
        install_snapcraft unless which 'snapcraft'
      end

      def login
        info :login
        shell :login, assert: 'Failed to authenticate: %{err}', info: '%{out}', capture: true
      end

      def validate
        error :no_snaps if snaps.empty?
        error :multiple_snaps if snaps.size > 1
      end

      def deploy
        info :deploy
        shell :deploy, snap_path, channel
      end

      def snap_path
        snaps.first
      end

      def snap_paths
        snaps.join(', ')
      end

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
