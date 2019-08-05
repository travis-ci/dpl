require 'dpl/version'
require 'net/http'
require 'securerandom'

module Dpl
  module Providers
    class Testfairy < Provider
      status :dev

      description sq(<<-str)
        tbd
      str

      gem 'json', '~> 2.2.0'
      gem 'multipart-post', '~> 2.0.0', require: 'net/http/post/multipart'

      opt '--api_key KEY', 'TestFairy API key', required: true, secret: true
      opt '--app_file FILE', 'Path to the app file that will be generated after the build (APK/IPA)', required: true
      opt '--symbols_file FILE', 'Path to the symbols file'
      opt '--testers_groups GROUPS', 'Tester groups to be notified about this build', example: 'e.g. group1,group1'
      opt '--notify', 'Send an email with a changelog to your users'
      opt '--auto_update', 'Automaticall upgrade all the previous installations of this app this version'
      opt '--video_quality QUALITY', 'Video quality settings (one of: high, medium or low', default: 'high'
      # the readme is a lil malformatted here. various google hits suggest this should be an integer
      # https://docs.openstack.org/infra/jenkins-job-builder/publishers.html says valid values are
      # 1, 2, 5 though ...
      opt '--screenshot_interval INTERVAL', 'Interval at which screenshots are taken, in seconds', type: :integer, enum: [1, 2, 10]
      opt '--max_duration DURATION', 'Maximum session recording length (max: 24h)', default: '10m', example: '20m or 1h'
      opt '--data_only_wifi', 'Send video and recorded metrics only when connected to a wifi network.'
      opt '--record_on_background', 'Collect data while the app is on background.'
      opt '--video', 'Video recording settings', default: true
      opt '--metrics METRICS', 'Comma_separated list of metrics to record', see: 'http://docs.testfairy.com/Upload_API.html'
      # mentioned in the readme, but not in the previous implementation
      opt '--icon_watermark', 'Add a small watermark to the app icon'
      opt '--advanced_options OPTS', 'Comma_separated list of advanced options', example: 'option1,option2'

      URL = 'http://api.testfairy.com/api/upload'
      UA  = "Travis CI dpl version=#{Dpl::VERSION}"

      msgs deploy: 'Uploading to TestFairy: %s',
           done:   'Done. Check your build at %s'

      def deploy
        info :deploy, pretty_print(params)
        body = JSON.parse(http.request(request).body)
        error body['message'] if body['status'] == 'fail'
        info :done, body['build_url']
      end

      private

        def params
          @params ||= compact(
            'api_key': api_key,
            'apk_file': file(app_file),
            'symbols_file': file(symbols_file),
            'video-quality': video_quality,
            'screenshot-interval': screenshot_interval,
            'max-duration': max_duration,
            'testers-groups': testers_groups,
            'metrics': metrics,
            'data-only-wifi': bool(data_only_wifi),
            'record-on-background': bool(record_on_background),
            'video': bool(video),
            'notify': bool(notify),
            'auto-update': bool(auto_update),
            'icon-watermark': bool(icon_watermark),
            'advanced-options': advanced_options,
            'changelog': changelog
          )
        end

        def changelog
          git_log "--pretty=oneline --abbrev-commit #{commits}" if commits
        end

        def commits
          ENV['TRAVIS_COMMIT_RANGE']
        end

        def request
          Net::HTTP::Post::Multipart.new(uri.path, params, 'User-Agent' => UA)
        end

        def http
          Net::HTTP.start(uri.host, uri.port)
        end

        def uri
          @uri ||= URI.parse(URL)
        end

        def file(path)
          UploadIO.new(path, '', File.basename(path)) if path
        end

        def bool(obj)
          obj ? 'on' : 'off' unless obj.nil?
        end

        def pretty_print(params)
          params = params.map do |key, value|
            value = obfuscate(value) if key == :api_key
            value = value.path if value.respond_to?(:path)
            [key, value]
          end
          JSON.pretty_generate(params.to_h)
        end
    end
  end
end
