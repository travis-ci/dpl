# frozen_string_literal: true

module Dpl
  module Providers
    class Nuget < Provider
      status :alpha

      full_name 'nuget'

      description sq(<<-STR)
        tbd
      STR

      env :nuget, :dotnet

      opt '--api_key KEY', 'NuGet registry API key', required: true, secret: true, note: 'can be retrieved from your NuGet registry provider', see: 'https://docs.npmjs.com/creating-and-viewing-authentication-tokens'
      opt '--registry URL', 'NuGet registry url', required: true, eg: 'https://www.myget.org/F/org-name/api/v2/package'
      opt '--src SRC', 'The nupkg file(s) to publish', default: '*.nupkg'
      opt '--no_symbols', 'Do not push symbols, even if present'
      opt '--skip_duplicate', 'Do not overwrite existing packages'

      msgs login: 'Authenticating with API key %{api_key}',
           push: 'Pushing package %{src} to %{registry}'

      cmds push: 'dotnet nuget push %{src} -k %{api_key} -s %{registry} %{push_opts}'

      errs push: 'Failed to push'

      def deploy
        info :login
        shell :push
      end

      private

      def push_opts
        opts_for(%i[no_symbols skip_duplicate], dashed: true)
      end
    end
  end
end
