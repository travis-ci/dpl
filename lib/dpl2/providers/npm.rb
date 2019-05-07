module Dpl
  module Providers
    class Npm < Provider
      summary 'Npm deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
