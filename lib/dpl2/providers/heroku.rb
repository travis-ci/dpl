module Dpl
  module Providers
    class Heroku < Provider
      summary 'Heroku deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
