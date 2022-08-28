module Dpl
  module Providers
    class Script < Provider
      register :script

      status :stable

      summary 'Minimal provider that executes a custom command'

      description sq(<<-str)
        This deployment provider executes custom commands. This is usually a
        single script that is contained in your repository, but it can be any
        command executable in the build environment.

        It is possible to pass arguments to a script deployment like so:

          dpl script -s './scripts/deploy.sh production --verbose'

        Deployment will be marked a failure if the script exits with nonzero
        status.
      str

      opt '-s', '--script SCRIPT', 'The script to execute', type: :array, required: true

      def deploy
        script.each do |script|
          shell script, assert: 'Script failed with status %{status}'
        end
      end
    end
  end
end
