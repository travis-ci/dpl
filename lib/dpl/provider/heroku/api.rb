require 'json'
require 'shellwords'
require 'logger'

module DPL
  class Provider
    module Heroku
      class API < Generic
        attr_reader :build_id

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
          context.shell "curl #{Shellwords.escape(put_url)} -X PUT -H 'Content-Type:' -H 'Accept: application/vnd.heroku+json; version=3' --data-binary @#{archive_file}"
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
            context.shell "curl #{Shellwords.escape(output_stream_url)} -H 'Accept: application/vnd.heroku+json; version=3'"
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

      end
    end
  end
end
