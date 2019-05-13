module Dpl
  class Interpolation < Hash
    attr_reader :obj

    def initialize(obj)
      super() { |_, key| lookup(key.to_s) }
      @obj = obj
    end

    def lookup(key)
      if key.start_with?('obfuscated_')
        key = key.sub('obfuscated_', '')
        obj.obfuscate(lookup(key))
      else
        obj.send(key).to_s
      end
    end
  end
end
