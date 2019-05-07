module Dpl
  module Providers
    class Packagecloud < Provider
      summary 'Packagecloud deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
