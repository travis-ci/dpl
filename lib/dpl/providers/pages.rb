module Dpl
  module Providers
    class Pages < Provider
      def self.new(ctx, args)
        return super unless registry_key.to_sym == :pages
        arg = args.detect { |arg| arg.include? '--strategy' }
        strategy = arg ? arg.split('=', 2).last : 'git'
        Provider[:"pages:#{strategy}"].new(ctx, args)
      end

      env :github, :pages

      opt '--strategy NAME', 'GitHub Pages deployment strategy', default: 'git', enum: %w(api git), internal: true
    end
  end
end

require 'dpl/providers/pages/git'
require 'dpl/providers/pages/api'
