require 'json'

module DPL
  class Provider
    module Heroku
      class Generic < Provider
        attr_reader :app, :user

        def needs_key?
          false
        end

        def faraday
          return @conn if @conn
          headers = { "Accept" => "application/vnd.heroku+json; version=3" }

          if options[:user] and options[:password]
            # no-op
          else
            headers.merge!({ "Authorization" => "Bearer #{option(:api_key)}" })
          end

          @conn = Faraday.new( url: 'https://api.heroku.com', headers: headers ) do |faraday|
            if options[:user] and options[:password]
              faraday.basic_auth(options[:user], options[:password])
            end
            if log_level = options[:log_level]
              logger = Logger.new($stderr)
              logger.level = Logger.const_get(log_level.upcase)

              faraday.response :logger, logger do | logger |
                logger.filter(/(.*Authorization: ).*/,'\1[REDACTED]')
              end
            end
            faraday.adapter Faraday.default_adapter
          end
        end

        def check_auth
          response = faraday.get('/account')

          if response.success?
            email = JSON.parse(response.body)["email"]
            @user = email
            log "authentication succeeded"
          else
            handle_error_response(response)
          end
        end

        def handle_error_response(response)
          error_response = JSON.parse(response.body)
          error "API request failed.\nMessage: #{error_response["message"]}\nReference: #{error_response["url"]}"
        end

        def check_app
          log "checking for app #{option(:app)}"
          response = faraday.get("/apps/#{option(:app)}")
          if response.success?
            @app = JSON.parse(response.body)
            log "found app #{@app["name"]}"
          else
            handle_error_response(response)
          end
        end

        def restart
          response = faraday.delete "/apps/#{option(:app)}/dynos" do |req|
            req.headers['Content-Type'] = 'application/json'
          end
          unless response.success?
            handle_error_response(response)
          end
        end

        def run(command)
          response = faraday.post "/apps/#{option(:app)}/dynos" do |req|
            req.headers['Content-Type'] = 'application/json'
            req.body = {"command" => command, "attach" => true}.to_json
          end
          if response.success?
            rendezvous_url = JSON.parse(response.body)["attach_url"]
            Rendezvous.start(url: rendezvous_url)
          else
            handle_error_response(response)
          end
        end
      end
    end
  end
end
