module Dpl
  module Providers
    class CloudFiles < Provider
      summary 'CloudFiles deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
