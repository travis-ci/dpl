require 'json'

module Dpl
  module Providers
    class Heroku
      class Api < Heroku
        full_name 'Heroku API'

        description sq(<<-str)
          tbd
        str

        opt '--api_key KEY', 'Heroku API key'
        # mentioned in the code
        opt '--version VERSION' # used in triggering a build, not sure this should be exposed?

        msgs pack:    'Creating application archive',
             upload:  'Uploading application archive',
             build:   'Triggering Heroku build (deployment)',
             pending: 'Heroku build still pending',
             failed:  'Heroku build failed'

        cmds pack:    'tar -zcf %{escaped_archive_file} --exclude .git .',
             upload:  'curl %{curl_opts} %{escaped_put_url} -X PUT -H "Content-Type:" -H "Accept: application/vnd.heroku+json; version=3" -H "User-Agent: %{user_agent}" --data-binary @%{archive_file}',
             log:     'curl %{curl_opts} %{escaped_output_stream_url} -H "Accept: application/vnd.heroku+json; version=3" -H "User-Agent: %{user_agent}"'

        attr_reader :data

        def deploy
          pack
          upload
          build
          log
          verify
        end

        private
          def pack
            info :pack
            shell :pack
          end

          def upload
            info :upload
            shell :upload
          end

          def build
            info :build
            res = http.post("/apps/#{app}/builds") do |req|
              req.headers['Content-Type'] = 'application/json'
              req.body = JSON.dump(source_blob: { url: get_url, version: version })
            end
            handle_error(res) unless res.success?
            @data = symbolize(JSON.parse(res.body))
          end

          def log
            shell :log
          end

          def verify
            loop do
              case build_status
              when 'pending'
                info :pending
                sleep 5
              when 'succeeded'
                break
              else
                error :failed
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
            # this says the endpoint /sources is deprecated: https://devcenter.heroku.com/articles/platform-api-reference#source
            # this says to use /apps/example-app/sources: https://devcenter.heroku.com/articles/build-and-release-using-the-api#sources-endpoint
            @source ||= begin
              res = http.post('/sources')
              handle_error(res) unless res.success?
              JSON.parse(res.body)['source_blob']
            end
          end

          def build_id
            data[:id]
          end

          def output_stream_url
            data[:output_stream_url]
          end

          def version
            super || git_sha
          end

          def curl_opts
            $stdout.isatty ? '' : ' -sS'
          end

          def symbolize(hash)
            hash.map { |key, value| [key.to_sym, value] }.to_h
          end
      end
    end
  end
end
