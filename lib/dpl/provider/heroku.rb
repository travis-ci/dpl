module DPL
  class Provider
    module Heroku
      autoload :Anvil, 'dpl/provider/heroku/anvil'
      autoload :Git,   'dpl/provider/heroku/git'

      extend self

      def new(context, options)
        strategy = options[:strategy] || 'anvil'
        constant = constants.detect { |c| c.to_s.downcase == strategy }
        raise Error, 'unknown strategy %p' % strategy unless constant
        const_get(constant).new(context, options)
      end
    end
  end
end
