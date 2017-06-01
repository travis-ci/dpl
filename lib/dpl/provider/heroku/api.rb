require 'json'
require 'shellwords'

module DPL
  class Provider
    module Heroku
      class API < Generic
        attr_reader :build_id
        requires 'faraday'

        def check_auth
          response = faraday.get('/account')

          if response.success?
            email = JSON.parse(response.body)["email"]
            log "authenticated as #{email}"
          else
            handle_error_response(response)
          end

          # options = {
          #   method: :get,
          #   path: "/account",
          #   headers: { "Accept" => "application/vnd.heroku+json; version=3" },
          #   expects: [200]
          # }

          # response = api.request(options).body
          # user = response.fetch('email')
          # log "authenticated as #{user}"
        end

        def faraday
          @conn ||= Faraday.new(
            url: 'https://api.heroku.com',
            headers: {
              "Authorization" => "Bearer #{option(:api_key)}",
              "Accept" => "application/vnd.heroku+json; version=3"
              },
            ) do |faraday|
            faraday.response :logger do | logger |
              logger.filter(/#{option(:api_key)}/,'[REMOVED]')
            end
            faraday.adapter Faraday.default_adapter
          end
        end

        def check_app
          log "checking for app #{option(:app)}"
          response = faraday.get("/apps/#{option(:app)}")
          if response.success?
            name = JSON.parse(response.body)["name"]
            log "found app #{name}"
          else
            handle_error_response(response)
          end
        end

        def handle_error_response(response)
          error_response = JSON.parse(response.body)
          error "#{error_response["message"]} #{error_response["url"]}"
        end

        def push_app
          pack_archive
          upload_archive
          trigger_build
          verify_build
        end

        def archive_file
          Shellwords.escape("#{context.env['HOME']}/.dpl.#{option(:app)}.tgz")
        end

        def pack_archive
          log "creating application archive"
          context.shell "tar -zcf #{archive_file} --exclude .git ."
        end

        def upload_archive
          log "uploading application archive"
          context.shell "curl #{Shellwords.escape(put_url)} -X PUT -H 'Content-Type:' --data-binary @#{archive_file}"
        end

        def trigger_build
          log "triggering new deployment"
          response = faraday.post("/apps/#{option(:app)}/builds") do |req|
            req.headers['Content-Type'] = 'application/json'
            req.body = {
              "source_blob" => {
                "url" => get_url,
                "version" => version
              }
              }.to_json
          end

          if response.success?
            @build_id  = JSON.parse(response.body)['id']
            output_stream_url = JSON.parse(response.body)['output_stream_url']
            context.shell "curl #{Shellwords.escape(output_stream_url)}"
          else
            handle_error_response(response)
          end
        end

        def verify_build
          loop do
            response = faraday.get("/apps/#{option(:app)}/builds/#{build_id}/result")
            exit_code = JSON.parse(response.body)['exit_code']
            if exit_code.nil?
              log "heroku build still pending"
              sleep 5
              next
            elsif exit_code == 0
              break
            else
              error "deploy failed, build exited with code #{exit_code}"
            end
          end
        end

        def get_url
          source_blob.fetch("get_url")
        end

        def put_url
          source_blob.fetch("put_url")
        end

        def source_blob
          return @source_blob if @source_blob

          response = faraday.post('/sources')

          if response.success?
            @source_blob = JSON.parse(response.body)["source_blob"]
          else
            handle_error_response(response)
          end
        end

        def version
          @version ||= options[:version] || context.env['TRAVIS_COMMIT'] || `git rev-parse HEAD`.strip
        end

        # def get(subpath, options = {})
        #   options = {
        #     method: :get,
        #     path: "/apps/#{option(:app)}/#{subpath}",
        #     headers: { "Accept" => "application/vnd.heroku+json; version=3" },
        #     expects: [200]
        #   }.merge(options)

        #   api.request(options).body
        # end

        # def post(subpath, body = nil, options = {})
        #   options = {
        #     method: :post,
        #     path: "/apps/#{option(:app)}/#{subpath}",
        #     headers: { "Accept" => "application/vnd.heroku+json; version=3" },
        #     expects: [200, 201]
        #   }.merge(options)

        #   if body
        #     options[:body]                    = JSON.dump(body)
        #     options[:headers]['Content-Type'] = 'application/json'
        #   end

        #   response = api.request(options).body
        # end

        def restart
          response = faraday.delete "/apps/#{option(:app)}/dynos"
          # options = {
          #   method: :delete,
          #   path: "/apps/#{option(:app)}/dynos",
          #   headers: { "Accept" => "application/vnd.heroku+json; version=3" },
          #   expects: [200, 201, 202]
          # }

          # api.request(options).body
        end

        def run(command)
          response = faraday.post "/apps/#{option(:app)}/dynos" do |req|
            req.body = {"command" => command, "attach" => true}.to_json
          end
          # post("dynos", {"command" => command, "attach" => true})
        end
      end
    end
  end
end
