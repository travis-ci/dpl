module Dpl
  module Providers
    class Transifex < Provider
      summary 'Transifex deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
