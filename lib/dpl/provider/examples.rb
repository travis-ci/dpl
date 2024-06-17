# frozen_string_literal: true

module Dpl
  class Examples < Struct.new(:const)
    def cmds
      examples.map(&:cmd).join("\n")
    end

    def full_config
      full.config
    end

    def configs
      examples.map(&:config)
    end

    def examples
      [requireds, required, many].flatten.compact.uniq
    end

    def requireds
      requireds_opts.map { |opts| example(opts) }
    end

    def required
      opts = required_opts
      example(opts)
    end

    def many
      opts = const.opts.opts
      opts = order(opts)
      opts = without_required(opts)
      opts = with_required(opts)
      opts = filter(opts)
      opts = opts[0, 5]
      example(opts)
    end

    def full
      opts = const.opts.opts
      opts = filter(opts)
      example(opts)
    end

    def filter(opts)
      opts = opts.reject(&:internal?)
      opts.reject { |opt| opt.name == :help }
    end

    def order(opts)
      cmmn = const.superclass.opts.opts
      opts - cmmn + cmmn
    end

    def with_required(opts)
      requireds = requireds_opts.first || []
      opts = requireds + required_opts + opts
      opts.uniq
    end

    def without_required(opts)
      opts -= const.required.flatten.map { |key| const.opts[key] }
      opts - required_opts.map(&:opts)
    end

    def example(opts)
      return unless opts.any?

      opts = required_opts.concat(opts).uniq.compact
      Example.new(const, opts)
    end

    def requireds_opts
      opts = const.required.flatten(1)
      opts.map { |keys| Array(keys).map { |key| const.opts[key] } }
    end

    def required_opts
      const.opts.select(&:required?)
    end
  end

  class Example < Struct.new(:const, :opts)
    def config
      config = opts_for(opts)
      config = config.merge(strategy: strategy) # hmm.
      compact(config)
    end

    def strategy
      const.registry_key.to_s.split(':').last if const.registry_key.to_s.include?(':')
    end

    def cmd
      "dpl #{name} #{strs_for(opts)}"
    end

    def ==(other)
      const == other.const && opts == other.opts
    end

    def name
      const.registry_key.to_s.split(':').join(' ')
    end

    def opts_for(opts)
      opts.map { |opt| [opt.name, value_for(opt)] }.to_h
    end

    def strs_for(opts)
      opts.map { |opt| str_for(opt) }.join(' ')
    end

    def str_for(opt)
      "--#{opt.name} #{value_for(opt)}".strip
    end

    def value_for(opt)
      return if opt.type == :flag
      return 1 if opt.type == :integer
      return opt.enum.first if opt.enum?

      str = opt.strs.detect { |str| str =~ /^--#{opt.name} (.*)$/ } && ::Regexp.last_match(1)
      str ? str.downcase : 'str'
    end

    def compact(hash)
      hash.reject { |_, value| value.nil? }
    end
  end
end
