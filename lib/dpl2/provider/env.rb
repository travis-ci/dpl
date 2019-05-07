module Dpl
  module Env
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # should this sit in Cl?
      def env(prefix = nil)
        return @prefix = "#{prefix.to_s.upcase}_" if prefix
        return {} unless @prefix
        opts = ENV.select { |key, _| key.to_s.start_with?(@prefix) }
        opts.map { |key, value| [key.sub(@prefix, '').downcase.to_sym, value] }.to_h
      end
    end

    def opts
      @opts = self.class.env.merge(super)
    end
  end
end
