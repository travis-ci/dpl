require 'json'
require 'shellwords'

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
          context.shell "tar -zcf #{archive_file} ."
        end

        def upload_archive
          log "uploading application archive"
          context.shell "curl #{Shellwords.escape(put_url)} -X PUT -H 'Content-Type:' --data-binary @#{archive_file}"
        end

        def trigger_build
          log "triggering new deployment"
          response   = post(:builds, source_blob: { url: get_url, version: version })
          @build_id  = response.fetch('id')
          stream_url = response.fetch('output_stream_url')
          context.shell "curl #{Shellwords.escape(stream_url)}"
        end

        def verify_build
          loop do
            response = get("builds/#{build_id}/result")
            exit_code = response.fetch('exit_code')
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
          @source_blog ||= post(:sources).fetch("source_blob")
        end

        def version
          @version ||= options[:version] || context.env['TRAVIS_COMMIT'] || `git rev-parse HEAD`.strip
        end

        def get(subpath, options = {})
          options = {
            method: :get,
            path: "/apps/#{option(:app)}/#{subpath}",
            headers: { "Accept" => "application/vnd.heroku+json; version=3.streaming-build-output" },
            expects: [200]
          }.merge(options)

          api.request(options).body
        end

        def post(subpath, body = nil, options = {})
          options = {
            method: :post,
            path: "/apps/#{option(:app)}/#{subpath}",
            headers: { "Accept" => "application/vnd.heroku+json; version=3.streaming-build-output" },
            expects: [200, 201]
          }.merge(options)

          if body
            options[:body]                    = JSON.dump(body)
            options[:headers]['Content-Type'] = 'application/json'
          end

          api.request(options).body
        end
      end
    end
  end
end
