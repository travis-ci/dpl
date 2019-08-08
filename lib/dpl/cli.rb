require 'cl'

module Dpl
  class Cli < Cl
    def self.new(ctx = nil, cmd = nil)
      super(ctx || Dpl::Ctx::Bash.new, cmd || 'dpl')
    end

    def run(args)
      args = untaint(args)
      args = with_provider_opt(args)
      super
    end

    # Tainting is being used for automatically obfuscating values for secure
    # options, so we want to untaint all incoming args here.
    def untaint(args)
      args.map(&:dup).each(&:untaint)
    end

    # bc with travis-build dpl v1 integration
    def with_provider_opt(args)
      return args unless arg = args.detect { |arg| arg.include?('--provider') }
      args.delete(arg)
      [arg.split('=').last, *args]
    end
  end
end
