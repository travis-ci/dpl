module Dpl
  module Providers
    class Releases < Provider
      summary 'Releases deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
