module Dpl
  module Env
    def self.included(base)
      base.extend(ClassMethods)
    end

    # should this sit in Cl?
    module ClassMethods
      attr_reader :env_prefixes

      def env(*strs)
        opts = strs.last.is_a?(Hash) ? strs.pop : {}
        if strs.any?
          strs = strs.map(&:to_s).map(&:upcase)
          @env_prefixes = strs.map { |str| "#{str.to_s.upcase}_" }
          # allow unconventional ENV vars such as GOOGLECLOUDKEYFILE
          @env_prefixes += strs if opts[:allow_skip_underscore]
        elsif env_prefixes
          opts = ENV.select { |key, _| prefixed?(key) }
          opts.map { |key, value| [unprefix(key).downcase.to_sym, value] }.to_h
        else
          {}
        end
      end

      def prefixed?(key)
        env_prefixes.any? { |prefix| key.to_s.start_with?(prefix) }
      end

      def unprefix(key)
        env_prefixes.inject(key) { |key, prefix| key.sub(prefix, '') }
      end
    end

    def opts
      @opts = self.class.env.merge(super)
    end
  end
end
