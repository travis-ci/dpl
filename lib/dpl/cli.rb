require 'cl'

module Dpl
  class Cli < Cl
    def self.new(ctx = nil, cmd = nil)
      super(ctx || Dpl::Ctx::Bash.new, cmd || 'dpl')
    end

    def run(args)
      args = with_provider_opt(args)
      super
    end

    # bc with travis-build dpl v1 integration
    def with_provider_opt(args)
      return args unless arg = args.detect { |arg| arg.include?('--provider') }
      args.delete(arg)
      [arg.split('=').last, *args]
    end
  end
end
