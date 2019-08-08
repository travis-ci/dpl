module Support
  module Matchers
    module Shared
      attr_reader :cmd

      def stringify(hash)
        hash.map { |key, value| [key.to_s, value] }.to_h
      end

      def match?(other, str = self.str)
        str.is_a?(Regexp) ? str.match(other) : str == other
      end

      def indent(str)
        return str if str.lines.size < 2
        str.lines[0] + str.lines[1..-1].map { |str| "#{' ' * 2}#{str}" }.join
      end
    end
  end
end
