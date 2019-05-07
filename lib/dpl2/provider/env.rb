module Dpl
  module Env
    def self.included(base)
      base.extend(ClassMethods)
    end

    # should this sit in Cl?
    module ClassMethods
      attr_reader :env_prefixes

      def env(*strs)
        if strs.any?
          # this should not have the additional prefix str without the underscore
          # appended to it, but only the one with an underscore. however, we have
          # accepted unconventional ENV vars such as GOOGLECLOUDKEYFILE, so for the
          # time being this accepts both variants.
          @env_prefixes = strs.map do |str|
            ["#{str.to_s.upcase}_", str.to_s.upcase]
          end.flatten
        elsif !env_prefixes
          {}
        else
          opts = ENV.select { |key, _| prefixed?(key) }
          opts.map { |key, value| [unprefix(key).downcase.to_sym, value] }.to_h
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
