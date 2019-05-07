module Dpl
  module Providers
    class CodeDeploy < Provider
      summary 'CodeDeploy deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER', 'anynines username', required: true
    end
  end
end
