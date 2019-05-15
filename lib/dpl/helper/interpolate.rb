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
    # Named variable names need to match methods on the provider instance,
    # which will be called in order to evaluate the value to be interpolated.
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
    def interpolate(str, args = [])
      args.any? ? str % args : Interpolate.new(str, self).apply
    end

    class Interpolate < Struct.new(:str, :obj)
      MODIFIER = %i(obfuscate escape quote)
      PATTERN  = /%\{(\w+)\}/

      def apply
        str.gsub(PATTERN) { |match| lookup($1.to_s) }
      end

      def lookup(key)
        if mod = modifier(key)
          key = key.sub("#{mod}d_", '')
          obj.send(mod, lookup(key))
        else
          obj.send(key).to_s
        end
      end

      def modifier(key)
        MODIFIER.detect { |mod| key.start_with?("#{mod}d_") }
      end
    end
  end
end
