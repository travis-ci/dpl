require 'cl'

module Dpl
  class Cli < Cl
    def run(args)
      args = args - %w(--provider --strategy)
      super
    end
  end
end
