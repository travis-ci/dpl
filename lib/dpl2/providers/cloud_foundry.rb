module Dpl
  module Providers
    class CloudFoundry < Provider
      summary 'CloudFoundry deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
