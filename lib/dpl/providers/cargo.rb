module Dpl
  module Providers
    class Cargo < Provider
      status :alpha

      description sq(<<-str)
        tbd
      str

      env :cargo

      opt '--token TOKEN', 'Cargo registry API token', required: true, secret: true

      cmds publish: 'cargo publish --token %{token}'

      def deploy
        shell :publish
      end
    end
  end
end
