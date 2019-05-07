module Dpl
  module Providers
    class OpenShift < Provider
      summary 'Openshift deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
