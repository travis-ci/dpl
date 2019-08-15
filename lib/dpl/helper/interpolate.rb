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

    # Obfuscates the given string.
    #
    # Replaces all but the first N characters with asterisks, and paddes
    # the string to a standard length of 20 characters. N depends on the
    # length of the original string.
    def obfuscate(str, opts = {})
      return str if opts[:secure] || !str.tainted?
      keep = (str.length / (4.0 + str.length / 5).round).round
      keep = 1 if keep == 0
      str[0, keep] + '*' * (20 - keep)
    end

    class Interpolator < Struct.new(:str, :obj, :args, :opts)
      include Interpolate

      MODIFIER = %i(obfuscate escape quote)
      PATTERN  = /%\{(\w+)\}/
      UPCASE   = /^[A-Z_]+$/

      def apply
        str = interpolate(self.str)
        str = obfuscate(str) unless opts[:secure]
        str = str.gsub('  ', ' ') if str.lines.size == 1
        str
      end

      def interpolate(str)
        str = str % args if args.is_a?(Array) && args.any?
        str.gsub(PATTERN) { lookup($1.to_sym) }
      end

      def obfuscate(str)
        secrets(str).inject(str) do |str, secret|
          str.gsub(secret, super(secret))
        end
      end

      def secrets(str)
        return [] unless str.is_a?(String) && str.tainted?
        opts = obj.class.opts.select(&:secret?)
        secrets = opts.map { |opt| obj.opts[opt.name] }.compact
        secrets.select { |secret| str.include?(secret) }
      end

      def lookup(key)
        if mod = modifier(key)
          key = key.to_s.sub("#{mod}d_", '')
          obj.send(mod, lookup(key))
        elsif key.to_s =~ UPCASE
          obj.class.const_get(key)
        elsif args.is_a?(Hash) && args.key?(key)
          args[key]
        else
          obj.send(key).to_s
        end
      end

      def modifier(key)
        MODIFIER.detect { |mod| key.to_s.start_with?("#{mod}d_") }
      end
    end
  end
end
