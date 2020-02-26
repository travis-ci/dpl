module Dpl
  module Providers
    class Nuget < Provider
      status :dev

      full_name 'nuget'

      description sq(<<-str)
        tbd
      str

      env :nuget, :dotnet

      opt '--api_key KEY', 'NuGet registry api key', required: true, secret: true, note: 'can be retrieved from your NuGet registry provider', see: 'https://docs.npmjs.com/creating-and-viewing-authentication-tokens'
      opt '--registry URL', 'NuGet registry url', required: true, eg: 'https://www.myget.org/F/org-name/api/v2/package'
      opt '--src SRC', 'nupkg file(s) to push', default: '*.nupkg'
      opt '--no_symbols', note: 'does not push symbols (even if present)'
      opt '--skip_duplicate', 'does not push packages with 409 Conflict response from the server'

      msgs login: 'Authenticating with API key %{api_key}',
           push:  'Pushing package %{src} to %{registry}'

      cmds push: 'dotnet nuget push %{src} -k %{api_key} -s %{registry} %{no_symbols_option} %{skip_duplicate_option}'

      errs push: 'Failed to push'

      def deploy
        info :login
        shell :push
      end

      private

        def no_symbols_option
          '--no-symbols' if no_symbols?
        end

        def skip_duplicate_option
          '--skip-duplicate' if skip_duplicate?
        end

    end
  end
end
