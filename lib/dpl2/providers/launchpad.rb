module Dpl
  module Providers
    class Launchpad < Provider
      summary 'Launchpad deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
