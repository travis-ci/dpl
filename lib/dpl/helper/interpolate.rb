module Dpl
  module Interpolate
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
