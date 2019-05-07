module Dpl
  module Providers
    class Gcs < Provider
      summary 'Gcs deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
