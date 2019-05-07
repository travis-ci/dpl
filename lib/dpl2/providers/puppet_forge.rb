module Dpl
  module Providers
    class PuppetForge < Provider
      summary 'PuppetForge deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
