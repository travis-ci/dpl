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
      provider = arg.split('=').last
      args.delete(arg)
      [provider, *args]
    end
  end
end
