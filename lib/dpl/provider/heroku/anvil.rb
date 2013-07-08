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
          response = Excon.post release_url,
            :body    => { "slug_url" => slug_url, "description" => "Travis CI deploy" }.to_json,
            :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

          print "\nDeploying slug "
          while response.status == 202
            location = response.headers['Location']
            response = Excon.get("https://:#{option(:api_key)}@cisaurus.heroku.com#{location}")
            sleep(1)
            print '.'
          end

          if response.status.between? 200, 299
            puts " success!"
          else
            raise Error, "deploy failed, anvil response: #{response.body}"
          end
        end

        def slug_url
          "https://api.anvilworks.org/slugs/4da48704-7495-416f-981a-83890a1c7e55.tgz"
          # @slug_url ||= begin
          #   ::Anvil.headers["X-Heroku-User"] = user
          #   ::Anvil.headers["X-Heroku-App"]  = option(:app)
          #   ::Anvil::Engine.build "."
          # end
        end

        def release_url
          "https://:#{option(:api_key)}@cisaurus.heroku.com/v1/apps/#{option(:app)}/release"
        end
      end
    end
  end
end