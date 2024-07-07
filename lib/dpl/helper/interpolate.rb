# frozen_string_literal: true

require 'uri'

module Dpl
  module Interpolate
    # Interpolates variables in the given string.
    #
    # Variables can be contained in scripts, shell commands, and messages.
    # They have the syntax `%{name}` or `%s` (or any other identifier supported
    # by [Kernel#sprintf](https://ruby-doc.org/core-2.6.3/Kernel.html#method-i-format)).
    #
    # This supports two styles of interpolation:
    #
    # * Named variables `%{name}` and
    # * Positional variables.
    #
    # Named variable names need to match constants on the provider class, or
    # methods on the provider instance, which will be called in order to
    # evaluate the value to be interpolated.
    #
    # Positional variables can be used if no corresponding method exists, e.g.
    # if the value that needs to be interpolated is an argument passed to a
    # local method.
    #
    # For example, using named variables:
    #
    #   ```ruby
    #   def upload_file
    #     interpolate('Uploading file %{file} to %{target}')
    #   end
    #
    #   def file
    #     './file_name'
    #   end
    #
    #   def target
    #     'target host'
    #   end
    #   ```
    #
    # Using positional variables:
    #
    #   ```ruby
    #   def upload_file(file, target)
    #     interpolate('Uploading file %s to %s', file, target)
    #   end
    #   ```
    #
    # Implementors are encouraged to use named variables when possible, but
    # are free to choose according to their needs.
    def interpolate(str, args = [], opts = {})
      args = args.shift if args.is_a?(Array) && args.first.is_a?(Hash)
      Interpolator.new(str, self, args || {}, opts).apply
    end

    # Interpolation variables as declared by the provider.
    #
    # By default this contains string option names, but additional
    # methods can be added using Provider::Dsl#vars.
    def vars
      self.class.vars
    end

    # Obfuscates the given string.
    #
    # Replaces all but the first N characters with asterisks, and paddes
    # the string to a standard length of 20 characters. N depends on the
    # length of the original string.
    def obfuscate(str, opts = {})
      return str if opts[:secure] || !str.blacklisted?

      keep = (str.length / (4.0 + str.length / 5).round).round
      keep = 1 if keep.zero?
      str[0, keep] + '*' * (20 - keep)
    end

    class Interpolator < Struct.new(:str, :obj, :args, :opts)
      include Interpolate

      MODIFIER = %i[obfuscate escape quote].freeze
      PATTERN  = /%\{(\$?[\w]+)\}/
      ENV_VAR  = /^\$[A-Z_]+$/
      UPCASE   = /^[A-Z_]+$/
      UNKNOWN  = '[unknown variable: %s]'

      def apply
        str = interpolate(self.str.to_s)
        str = obfuscate(str) unless opts[:secure]
        str = str.gsub('  ', ' ') if str.lines.size == 1
        str
      end

      def interpolate(str)
        str = str % args if args.is_a?(Array) && args.any?
        @blacklist_result = false
        str = str.to_s.gsub(PATTERN) do
          @blacklist_result = true
          normalize(lookup(::Regexp.last_match(1).to_sym))
        end
        @blacklist_result || (args.is_a?(Array) && args.any? { |arg| arg.is_a?(String) && arg.blacklisted? }) ? str.blacklist : str
      end

      def obfuscate(str)
        secrets(str).inject(str) do |str, secret|
          secret = secret.dup if secret.frozen?
          secret.blacklist if str.blacklisted?
          str.gsub(secret, super(secret))
        end
      end

      def secrets(str)
        return [] unless str.is_a?(String) && str.blacklisted?

        opts = obj.class.opts.select(&:secret?)
        secrets = opts.map { |opt| obj.opts[opt.name] }.compact
        secrets.select { |secret| str.include?(secret) }
      end

      def normalize(obj)
        obj.is_a?(Array) ? obj.join(' ') : obj.to_s
      end

      def lookup(key)
        if vars? && !var?(key)
          UNKNOWN % key
        elsif mod = modifier(key)
          key = key.to_s.sub("#{mod}d_", '')
          obj.send(mod, lookup(key))
        elsif key.to_s =~ ENV_VAR
          ENV[key.to_s.sub('$', '')]
        elsif key.to_s =~ UPCASE && obj.class.const_defined?(key)
          obj.class.const_get(key)
        elsif args.is_a?(Hash) && args.key?(key)
          args[key]
        elsif obj.respond_to?(key, true)
          obj.send(key)
        else
          raise KeyError, key
        end
      end

      def modifier(key)
        MODIFIER.detect { |mod| key.to_s.start_with?("#{mod}d_") }
      end

      def var?(key)
        vars.include?(key)
      end

      def vars
        opts[:vars]
      end

      def vars?
        !!vars
      end
    end
  end
end
