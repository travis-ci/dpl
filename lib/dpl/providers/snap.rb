module Dpl
  module Providers
    class Snap < Provider
      register :snap

      status :stable

      description sq(<<-str)
        tbd
      str

      env :snap

      opt '--token TOKEN', 'Snap API token', required: true, secret: true
      opt '--snap STR', 'Path to the snap to be pushed (can be a glob)', default: '**/*.snap'
      opt '--channel CHAN', 'Channel into which the snap will be released', default: 'edge'

      apt 'snapd', 'snap'

      cmds apt_get_update: 'sudo apt-get update -qq',
           update_snapd:   'sudo apt-get install snapd',
           install:        'sudo snap install snapcraft --classic',
           login:          'echo "%{token}" | snapcraft login --with -',
           deploy:         'snapcraft upload %{snap_path} --release=%{channel}'

      msgs login:          'Attemping to login ...',
           no_snaps:       'No snap found matching %{snap}',
           multiple_snaps: 'Multiple snaps found matching %{snap}: %{snap_paths}',
           deploy:         'Pushing snap %{snap_path}'

      def install
        return if which 'snapcraft'
        shell :apt_get_update
        shell :update_snapd
        shell :install
        ENV['PATH'] += ':/snap/bin'
      end

      def login
        shell :login, assert: 'Failed to authenticate: %{err}', success: '%{out}', capture: true
      end

      def validate
        error :no_snaps if snaps.empty?
        error :multiple_snaps if snaps.size > 1
      end

      def deploy
        shell :deploy
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
    end
  end
end
