module Dpl
  module Providers
    class PyPi < Provider
      summary 'PyPi deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
