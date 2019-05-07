module Dpl
  module Providers
    class EngineYard < Provider
      summary 'EngineYard deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
