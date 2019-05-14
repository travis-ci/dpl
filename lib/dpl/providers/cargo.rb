module Dpl
  module Providers
    class Cargo < Provider
      description <<~str
        tbd
      str

      opt '--token TOKEN', 'Cargo registry API token', required: true

      def deploy
        shell "cargo publish --token #{token}", assert: 'Publish failed'
      end
    end
  end
end
