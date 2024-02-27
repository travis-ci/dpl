# frozen_string_literal: true

module Dpl
  module Providers
    class Pages < Provider
      register :pages

      abstract

      env :github, :pages

      opt '--strategy NAME', 'GitHub Pages deployment strategy', default: 'git', enum: %w[api git]
    end
  end
end

require 'dpl/providers/pages/git'
require 'dpl/providers/pages/api'
