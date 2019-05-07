module Dpl
  module Providers
    class Rubygems < Provider
      summary 'Rubygems deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
