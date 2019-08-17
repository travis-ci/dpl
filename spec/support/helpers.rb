module Support
  module Helpers
    def only(hash, *keys)
      hash.select { |key, _| keys.include?(key) }.to_h
    end

    def except(hash, *keys)
      hash.reject { |key, _| keys.include?(key) }.to_h
    end

    def compact(hash)
      hash.reject { |_, value| value.nil? }
    end

    def stringify(obj)
      case obj
      when Hash  then obj.map { |key, obj| [key.to_s, stringify(obj)] }.to_h
      when Array then obj.map { |obj| stringify(obj) }
      else obj
      end
    end

    def symbolize(obj)
      case obj
      when Hash  then obj.map { |key, obj| [key.to_sym, symbolize(obj)] }.to_h
      when Array then obj.map { |obj| symbolize(obj) }
      else obj
      end
    end
  end
end
