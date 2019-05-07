module Dpl
  module Providers
    class Pages < Provider
      summary 'Pages deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
