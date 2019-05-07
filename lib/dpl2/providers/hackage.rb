module Dpl
  module Providers
    class Hackage < Provider
      summary 'Hackage deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
