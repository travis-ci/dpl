module DPL
  class Provider
    module Heroku
      class GitDeployKey < Git
        def needs_key?
          false
        end
      end
    end
  end
end
