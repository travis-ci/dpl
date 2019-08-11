require 'cl'

module Dpl
  class Cli < Cl
    def self.new(ctx = nil, name = 'dpl')
      ctx ||= Dpl::Ctx::Bash.new
      super
    end

    def run(args)
      args = untaint(args)
      args = with_provider_opt(args)
      super
    rescue UnknownCmd
      unknown_provider(args.first)
    rescue Error => e
      error(e)
    end

    # Tainting is being used for automatically obfuscating values for secure
    # options, so we want to untaint all incoming args here.
    def untaint(args)
      args.map(&:dup).each(&:untaint)
    end

    # backwards compatibility for travis-build dpl v1 integration
    def with_provider_opt(args)
      return args unless arg = args.detect { |arg| arg.include?('--provider') }
      args.delete(arg)
      [arg.split('=').last, *args]
    end

    def error(e)
      msg = "\e[31m#{e.message}\e[0m"
      msg = [msg, *e.backtrace].join("\n") if e.backtrace?
      abort msg
    end

    def unknown_provider(name)
      msg = "\e[31mUnknown provider: #{name}\e[0m"
      msg << "\nDid you mean: #{suggestions(name).join(', ')}?" if suggestions(name).any?
      abort msg
    end

    def suggestions(name)
      DidYouMean::SpellChecker.new(dictionary: providers).correct(name)
    end

    def providers
      Cl::Cmd.registry.keys.map(&:to_s)
    end
  end
end
