require 'json'
require 'shellwords'

module Dpl
  module Providers
    class Heroku
      class Api < Heroku
        attr_reader :build

        def deploy
          pack_archive
          upload_archive
          trigger_build
          fetch_log
          verify_build
        end

        private

          def pack_archive
            info "Creating application archive"
            shell "tar -zcf #{escape(archive_file)} --exclude .git ."
          end

          def upload_archive
            info "Uploading application archive"
            shell %(curl#{curl_opts} #{escape(put_url)} -X PUT -H "Content-Type:" -H "Accept: application/vnd.heroku+json; version=3" -H "User-Agent: #{user_agent}" --data-binary @#{archive_file})
          end

          def trigger_build
            info "triggering new deployment"
            res = http.post("/apps/#{app}/builds") do |req|
              req.headers['Content-Type'] = 'application/json'
              req.body = JSON.dump(source_blob: { url: get_url, version: version })
            end
            handle_error(res) unless res.success?
            @build = symbolize(JSON.parse(res.body))
          end

          def fetch_log
            shell %(curl#{curl_opts} #{escape(output_stream_url)} -H "Accept: application/vnd.heroku+json; version=3" -H "User-Agent: #{user_agent}")
          end

          def verify_build
            loop do
              case build_status
              when 'pending'
                info 'Heroku build still pending'
                sleep 5
              when 'succeeded'
                break
              else
                error 'Heroku build failed'
              end
            end
          end

          def build_status
            res = http.get("/apps/#{app}/builds/#{build_id}")
            JSON.parse(res.body)['status']
          end

          def archive_file
            "#{ENV['HOME']}/.dpl.#{app}.tgz"
          end

          def get_url
            source['get_url']
          end

          def put_url
            source['put_url']
          end

          def source
            # https://devcenter.heroku.com/articles/platform-api-reference#source
            # says the endpoint /sources is deprecated
            # https://devcenter.heroku.com/articles/build-and-release-using-the-api#sources-endpoint
            # says to use /apps/example-app/sources
            @source ||= begin
              res = http.post('/sources')
              handle_error(res) unless res.success?
              JSON.parse(res.body)['source_blob']
            end
          end

          def build_id
            build[:id]
          end

          def output_stream_url
            build[:output_stream_url]
          end

          def version
            super || ENV['TRAVIS_COMMIT'] || git_rev_parse('HEAD')
          end

          def curl_opts
            $stdout.isatty ? '' : ' -sS'
          end

          def escape(str)
            Shellwords.escape(str)
          end

          def symbolize(hash)
            hash.map { |key, value| [key.to_sym, value] }.to_h
          end
      end
    end
  end
end
