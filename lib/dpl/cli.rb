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
    rescue UnknownCmd => e
      unknown_provider(e)
    rescue UnknownOption => e
      unknown_option(e)
    rescue Cl::Error, Error => e
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
      msg = [msg, *e.backtrace].join("\n") if backtrace?(e)
      abort msg
    end

    def backtrace?(e)
      e.respond_to?(:backtrace?) && e.backtrace?
    end

    def unknown_provider(e)
      msg = "\e[31m#{e.message}\e[0m"
      msg << "\nDid you mean: #{e.suggestions.join(', ')}?" if e.suggestions.any?
      abort msg
    end

    def unknown_option(e)
      msg = "\e[31m#{e.message}\e[0m"
      msg << "\nDid you mean: #{e.suggestions.join(', ')}?" if e.suggestions.any?
      abort msg
    end

    def suggestions(name)
      return [] unless defined?(DidYouMean)
      DidYouMean::SpellChecker.new(dictionary: providers).correct(name)
    end
  end
end
