module Dpl
  class Interpolate < Hash
    attr_reader :obj

    def initialize(obj)
      super() { |_, key| lookup(key.to_s) }
      @obj = obj
    end

    MOD = %i(obfuscate escape quote)

    def lookup(key)
      if mod = modifier(key)
        key = key.sub("#{mod}d_", '')
        obj.send(mod, lookup(key))
      else
        obj.send(key).to_s
      end
    end

    def modifier(key)
      MOD.detect { |mod| key.start_with?("#{mod}d_") }
    end
  end
end
