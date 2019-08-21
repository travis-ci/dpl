module Dpl
  module Providers
    class Pages < Provider
      def self.new(ctx, args)
        return super unless registry_key.to_sym == :pages
        arg = args.detect { |arg| arg.include? '--strategy' }
        strategy = arg ? arg.split('=', 2).last : 'git'
        Provider[:"pages:#{strategy}"].new(ctx, args)
      end

      opt '--strategy NAME', 'GitHub Pages deployment strategy', default: 'git', enum: %w(api git), internal: true
      opt '--github_token TOKEN', 'GitHub oauth token with repo permission', required: true, secret: true
      opt '--repo SLUG', 'GitHub repo slug', default: :repo_slug
    end
  end
end

require 'dpl/providers/pages/git'
require 'dpl/providers/pages/api'
