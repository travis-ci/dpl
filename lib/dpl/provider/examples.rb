module Dpl
  class Examples < Struct.new(:cmd)
    def to_s
      [requireds, required, many].flatten.compact.uniq.join("\n")
    end

    def requireds
      requireds_opts.map { |opts| cmd_for(opts) }
    end

    def required
      opts = required_opts
      cmd_for(opts)
    end

    def many
      opts = cmd.opts.opts
      opts = order(opts)
      opts = without_required(opts)
      opts = with_required(opts)
      opts = opts.reject(&:internal?)
      opts = opts[0, 5]
      cmd_for(opts)
    end

    def order(opts)
      cmmn = cmd.superclass.opts.opts
      opts - cmmn + cmmn
    end

    def with_required(opts)
      requireds = requireds_opts.first || []
      opts = requireds + required_opts + opts
      opts.uniq
    end

    def without_required(opts)
      opts = opts - cmd.required.flatten.map { |key| cmd.opts[key] }
      opts - required_opts.map(&:opts)
    end

    def cmd_for(opts)
      return unless opts.any?
      opts = required_opts.concat(opts).uniq
      "dpl #{name} #{opts_for(opts)}"
    end

    def requireds_opts
      opts = cmd.required.flatten(1)
      opts.map { |keys| Array(keys).map { |key| cmd.opts[key] } }
    end

    def required_opts
      cmd.opts.select(&:required?)
    end

    def name
      cmd.registry_key.to_s.split(':').join(' ')
    end

    def opts_for(opts)
      opts.map { |opt| opt_for(opt) }.join(' ')
    end

    def opt_for(opt)
      "--#{opt.name} #{value_for(opt)}".strip
    end

    def value_for(opt)
      return if opt.type == :flag
      opt.enum? ? opt.enum.first : example_for(opt)
    end

    def example_for(opt)
      str = opt.strs.detect { |str| str =~ /^--#{opt.name} (.*)$/ } && $1
      str ? str.downcase : 'str'
    end
  end
end
