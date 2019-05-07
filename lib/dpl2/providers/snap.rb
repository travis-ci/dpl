module Dpl
  module Providers
    class Snap < Provider
      summary 'Snap deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
