module Dpl
  module Providers
    class NuGet < Provider
      status :dev

      full_name 'nuget'

      description sq(<<-str)
        tbd
      str

      env :nuget, :dotnet

      opt '--api_key KEY', 'NuGet registry api key', alias: :api_key, required: true, secret: true, note: 'can be retrieved from your NuGet registry provider', see: 'https://docs.npmjs.com/creating-and-viewing-authentication-tokens'
      opt '--registry URL', 'NuGet registry url', alias: :registry, required: true, note: 'ex: "https://www.myget.org/F/org-name/api/v2/package"'
      opt '--src SRC', 'nupkg file(s) to push', default: '*.nupkg', alias: :src
      opt '--no-symbols', 'does not push symbols (even if present).'
      #opt '--no-service-endpoint', 'does not append "api/v2/package" to the source URL'
      opt '--skip-duplicate', 'does not push packages with 409 Conflict response from the server'

      msgs login:    'Authenticating with API key %{api_key}'
           push:     'Pushing package %{src} to %{registry}'
           #version:  '.NET version: %{dotnet_version}',

      cmds push:  'dotnet nuget push %{src} -k %{api_key} -s %{registry} %{push_opts}'

      errs push:  'Failed to push'

      def deploy
        info :login
        info :push
        shell :push
      end

      private

        def push_opts
          opts_for(%i(no-symbols skip-duplicates), dashed: true)
        end

    end
  end
end
