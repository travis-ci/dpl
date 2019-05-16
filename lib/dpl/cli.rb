require 'cl'

module Dpl
  class Cli < Cl
    def run(args)
      # args = args - %w(--provider --strategy)
      args = args - %w(--provider)
      super
    end
  end
end
