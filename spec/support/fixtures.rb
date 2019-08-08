module Support
  module Fixtures
    def self.included(const)
      const.extend(Fixtures)
    end

    DIR = ::File.expand_path('../../fixtures', __FILE__)

    class << self
      def [](key)
        fixtures[key] || raise("No fixture found for #{key}")
      end

      def fixtures
        @fixtures ||= Dir["#{DIR}/**/*.json"].map do |path|
          [path.sub("#{DIR}/", ''), ::File.read(path)]
        end.to_h
      end
    end

    def fixture(namespace, key)
      Fixtures["#{namespace}/#{key}"]
    end

    fixtures
  end
end
