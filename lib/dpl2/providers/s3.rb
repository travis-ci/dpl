module Dpl
  module Providers
    class S3 < Provider
      summary 'S3 deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
