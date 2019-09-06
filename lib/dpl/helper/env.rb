module Dpl
  module Env
    def self.included(base)
      base.extend(ClassMethods)
    end

    class Env
      attr_reader :prefixes, :opts

      def initialize(args)
        @opts = args.last.is_a?(Hash) ? args.pop : {}
        strs = args.map(&:to_s).map(&:upcase)
        @prefixes = strs.map { |str| "#{str.to_s.upcase}_" }
        # allow unconventional ENV vars such as GOOGLECLOUDKEYFILE
        @prefixes += strs if opts[:allow_skip_underscore]
      end

      def env
        env = ENV.select { |key, _| prefixed?(key) }
        env.map { |key, value| [unprefix(key).downcase.to_sym, value] }.to_h
      end

      def prefixed?(key)
        prefixes.any? { |prefix| key.to_s.start_with?(prefix) }
      end

      def unprefix(key)
        prefixes.inject(key) { |key, prefix| key.sub(prefix, '') }
      end
    end

    # should this sit in Cl?
    module ClassMethods
      def env(*strs)
        if strs.any?
          @env = Env.new(strs)
        elsif env = @env || superclass.instance_variable_get(:@env)
          env.env
        else
          {}
        end
      end
    end

    def opts
      @opts ||= self.class.env.merge(super)
    end
  end
end
