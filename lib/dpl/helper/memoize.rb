# frozen_string_literal: true

module Memoize
  class ArgsError < StandardError; end

  module ClassMethods
    def memoize(name)
      ivar = :"@#{name.to_s.sub('?', '_predicate')}"
      prepend Module.new {
        define_method(name) do |*args|
          raise ArgsError, 'cannot pass arguments to memoized method %p' % name unless args.empty?
          return instance_variable_get(ivar) if instance_variable_defined?(ivar)

          instance_variable_set(ivar, super())
        end
      }
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
