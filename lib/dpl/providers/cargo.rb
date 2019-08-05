module Dpl
  module Providers
    class Cargo < Provider
      status :dev

      description sq(<<-str)
        tbd
      str

      opt '--token TOKEN', 'Cargo registry API token', required: true, secret: true

      cmds publish: 'cargo publish --token %{token}'

      def deploy
        shell :publish
      end
    end
  end
end
