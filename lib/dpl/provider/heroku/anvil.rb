module DPL
  class Provider
    module Heroku
      class Anvil < Git
        requires 'anvil-cli', :load => 'anvil/engine'
        requires 'excon' # comes with heroku
        requires 'json'

        def api
          raise Error, 'anvil deploy strategy only works with api_key' unless options[:api_key]
          super
        end

        def needs_key?
          false
        end

        def push_app
          Excon.post release_url,
            :body    => { "slug_url" => slug_url, "description" => "Travis CI deploy" }.to_json,
            :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

          while response.status == 202
            location = response.headers['Location']
            response = Excon.get("https://:#{token}@cisaurus.heroku.com#{location}")
            sleep(0.1)
            print '.'
          end

          raise Error, 'deploy failed' unless response.status == 200
        end

        def slug_url
          @slug_url ||= begin
            Anvil.headers["X-Heroku-User"] = user
            Anvil.headers["X-Heroku-App"]  = option(:app)
            Anvil::Engine.build "."
          end
        end

        def release_url
          "https://:#{option(:api_key)}@cisaurus.heroku.com/v1/apps/#{option(:app)}/release"
        end
      end
    end
  end
end