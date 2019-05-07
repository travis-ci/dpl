module Dpl
  module Providers
    class Deis < Provider
      summary 'Deis deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
