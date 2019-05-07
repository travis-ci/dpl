module Dpl
  module Providers
    class Firebase < Provider
      summary 'Firebase deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
