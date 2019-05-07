module Dpl
  module Providers
    class Surge < Provider
      summary 'Surge deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
