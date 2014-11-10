module DPL
  class Provider
    module Heroku
      autoload :Anvil,        'dpl/provider/heroku/anvil'
      autoload :API,          'dpl/provider/heroku/api'
      autoload :Generic,      'dpl/provider/heroku/generic'
      autoload :Git,          'dpl/provider/heroku/git'
      autoload :GitSSH,       'dpl/provider/heroku/git'
      autoload :GitDeployKey, 'dpl/provider/heroku/git_deploy_key'

      extend self

      def new(context, options)
        strategy = options[:strategy] || 'api'
        constant = constants.detect { |c| c.to_s.downcase == strategy.downcase.gsub(/\W/, '') }
        raise Error, 'unknown strategy %p' % strategy unless constant and constant != Generic
        const_get(constant).new(context, options)
      end
    end
  end
end
