# frozen_string_literal: true

require 'cl'

module Dpl
  class Cli < Cl
    def self.new(ctx = nil, name = 'dpl')
      ctx ||= Dpl::Ctx::Bash.new
      super
    end

    def run(args)
      super
    rescue UnknownCmd => e
      unknown_provider(e)
    rescue UnknownOption => e
      unknown_option(e)
    rescue Cl::Error, Error => e
      error(e)
    end

    def runner(args)
      super(normalize(args))
    end

    def normalize(args)
      args = unescape(args)
      args = untaint(args)
      args = with_cmd_opts(args, provider: 0, strategy: 1)
      args = with_strategy_default(args, :strategy) # should be a generic dispatch feature in Cl
      args
    end

    def unescape(args)
      args.map { |arg| arg.gsub('\\n', "\n") }
    end

    # Tainting is being used for automatically obfuscating values for secure
    # options, so we want to untaint all incoming args here.
    def untaint(args)
      args.map(&:dup).each(&:whitelist)
    end

    def with_cmd_opts(args, cmds)
      cmds.inject(args) do |args, (cmd, pos)|
        with_cmd_opt(args, cmd, pos)
      end
    end

    def with_cmd_opt(args, cmd, pos)
      return args unless opt = args.detect { |arg| arg.start_with?("--#{cmd}") }

      ix = args.index(opt)
      args.delete(opt)
      value = opt.include?('=') ? opt.split('=').last : args.delete_at(ix)
      args.insert(pos, value)
      args
    end

    STRATEGIES = {
      'heroku' => 'api',
      'pages' => 'git'
    }.freeze

    def with_strategy_default(args, _cmd)
      return args unless default = STRATEGIES[args.first]

      args.insert(1, default) if args[1].nil? || args[1].to_s.start_with?('--')
      args
    end

    def error(err)
      msg = "\e[31m#{err.message}\e[0m"
      msg = [msg, *err.backtrace].join("\n") if backtrace?(err)
      abort msg
    end

    def backtrace?(err)
      err.respond_to?(:backtrace?) && err.backtrace?
    end

    def unknown_provider(err)
      msg = "\e[31m#{err.message}\e[0m"
      msg << "\nDid you mean: #{err.suggestions.join(', ')}?" if err.suggestions.any?
      abort msg
    end

    def unknown_option(err)
      msg = "\e[31m#{err.message}\e[0m"
      msg << "\nDid you mean: #{err.suggestions.join(', ')}?" if err.suggestions.any?
      abort msg
    end

    def suggestions(name)
      return [] unless defined?(DidYouMean)

      DidYouMean::SpellChecker.new(dictionary: providers).correct(name)
    end
  end
end
