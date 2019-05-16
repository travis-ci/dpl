module Support
  module Require
    def self.included(base)
      base.before do
        const = base.described_class
        next unless const.respond_to?(:gem)
        paths = const.gem.map { |name, _, opts| opts[:require] || name }.flatten
        Array(paths).each { |path| Kernel.require(path) }
      end
    end
  end
end
