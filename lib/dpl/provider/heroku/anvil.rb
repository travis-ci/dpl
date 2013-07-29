module DPL
  class Provider
    module Heroku
      class Anvil < Git
        HEROKU_BUILDPACKS = ['ruby', 'nodejs', 'clojure', 'python', 'java', 'gradle', 'grails', 'scala', 'play']
        HEROKU_BUILDPACK_PREFIX = "https://github.com/heroku/heroku-buildpack-"
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
          sha = ENV['TRAVIS_COMMIT'] || `git rev-parse HEAD`.strip
          response = Excon.post release_url,
            :body    => { "slug_url" => slug_url, "description" => "Deploy #{sha} via Travis CI" }.to_json,
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
          @slug_url ||= begin
            ::Anvil.headers["X-Heroku-User"] = user
            ::Anvil.headers["X-Heroku-App"]  = option(:app)
            if HEROKU_BUILDPACKS.include? options[:buildpack]
              options[:buildpack] = HEROKU_BUILDPACK_PREFIX + options[:buildpack]
            end
            ::Anvil::Engine.build ".", :buildpack => options[:buildpack]
          rescue ::Anvil::Builder::BuildError => e
            raise Error, "deploy failed, anvil build error: #{e.message}"
          end
        end

        def release_url
          "https://:#{option(:api_key)}@cisaurus.heroku.com/v1/apps/#{option(:app)}/release"
        end
      end
    end
  end
end
