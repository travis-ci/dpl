module Support
  module Require
    def self.included(base)
      base.before do
        const = base.described_class
        next unless const.respond_to?(:gem)
        paths = const.gem.map { |_, _, opts| opts[:require] }
        paths.each { |path| Kernel.require(path) }
      end
    end
  end
end

