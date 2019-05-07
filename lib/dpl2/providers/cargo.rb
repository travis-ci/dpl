require 'dpl2/provider'

module Dpl
  module Providers
    class Cargo < Provider
      opt '--token TOKEN', 'Cargo registry API token', required: true

      def deploy
        shell "cargo publish --token #{token}", assert: 'Publish failed'
      end
    end
  end
end
