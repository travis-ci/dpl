module Dpl
  module Providers
    class ElasticBeanstalk < Provider
      summary 'ElasticBeanstalk deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
