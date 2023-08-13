# frozen_string_literal: true

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
        env = env.transform_keys { |key| unprefix(key).downcase.to_sym }
        env.transform_keys { |key| dealias(key) }
      end

      def description(cmd)
        strs = self.strs.map { |str| "#{str}_" }
        strs += self.strs if opts[:allow_skip_underscore]
        strs = strs.size > 1 ? "[#{strs.sort.join('|')}]" : strs.join
        "Options can be given via env vars if prefixed with `#{strs}`. #{example(cmd)}"
      end

      def example(cmd)
        return unless opt = cmd.opts.detect { |option| option.secret? }

        env = strs.map { |str| "`#{str}_#{opt.name.upcase}=<#{opt.name}>`" }
        env += strs.map { |str| "`#{str}#{opt.name.upcase}=<#{opt.name}>`" } if opts[:allow_skip_underscore]
        "E.g. the option `--#{opt.name}` can be given as #{sentence(env)}."
      end

      def sentence(strs)
        return strs.join if strs.size == 1

        [strs[0..-2].join(', '), strs[-1]].join(' or ')
      end

      private

      def dealias(key)
        opt = cmd.opts.detect { |option| option.aliases.include?(key) }
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
