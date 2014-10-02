require 'json'
require 'shellwords'

module DPL
  class Provider
    module Heroku
      class API < Git
        def needs_key?
          false
        end

        def user
          @user ||= api.get_user.body["email"]
        end

        def push_app
          pack_archive
          upload_archive
          trigger_build
        end

        def archive_file
          Shellwords.escape("#{ENV['HOME']}/.dpl.#{option(:app)}.tgz")
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
          stream_url = response.fetch('stream_url')
          context.shell "curl #{Shellwords.escape(stream_url)}"
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
          @version ||= begin
            sha = ENV['TRAVIS_COMMIT'] || `git rev-parse HEAD`.strip
            if ENV['TRAVIS_JOB_NUMBER']
              "Travis Build ##{ENV['TRAVIS_JOB_NUMBER']} (#{sha})"
            else
              sha
            end
          end
        end

        def post(subpath, body = nil, options = {})
          options = {
            method: :post,
            path: "/apps/#{option(:app)}/#{subpath}",
            headers: { "Accept" => "application/vnd.heroku+json; version=edge" },
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
