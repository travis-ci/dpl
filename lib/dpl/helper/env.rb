require 'dpl/helper/memoize'

module Dpl
  module Env
    def self.included(base)
      base.extend(ClassMethods)
    end

    class Env
      include Memoize
      # opts[:allow_skip_underscore] allows unconventional ENV vars such as GOOGLECLOUDKEYFILE

      attr_reader :cmd, :env, :strs, :keys, :opts

      def initialize(env, args)
        @env = env
        @opts = args.last.is_a?(Hash) ? args.pop : {}
        @strs = args.map(&:to_s).map(&:upcase)
      end

      def env(cmd)
        @cmd = cmd
        env = @env.select { |key, _| keys.include?(key) }
        env = env.map { |key, value| [unprefix(key).downcase.to_sym, value] }.to_h
        env.map { |key, value| [dealias(key), value] }.to_h
      end

      private

        def dealias(key)
          opt = cmd.opts.detect { |opt| opt.aliases.include?(key) }
          opt ? opt.name : key
        end

        def unprefix(key)
          strs.inject(key) { |key, str| key.sub(/^#{str}_?/, '') }
        end

        def keys
          keys = cmd.opts.map(&:name) + cmd.opts.map(&:aliases).flatten
          strs.map { |str| keys.map { |key| keys_for(str, key) } }.flatten
        end
        memoize :keys

        def keys_for(str, key)
          keys = [["#{str}_", key.upcase].join]
          keys << [str, key.upcase].join if opts[:allow_skip_underscore]
          keys
        end
    end

    # should this sit in Cl?
    module ClassMethods
      def env(*strs)
        if strs.any?
          @env = Env.new(ENV, strs)
        elsif env = @env || superclass.instance_variable_get(:@env)
          env.env(self)
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
