module DPL
  class Provider
    class TestFairy < Provider

      require "net/http"
      require 'net/http/post/multipart'
      require 'json'


      VERSION = "0.2"
      TAG = "-TestFairy-"
      SERVER = "http://api.testfairy.com"
      UPLOAD_URL_PATH = "/api/upload";

      def check_auth
        if !options[:app_file]
          error 'App file is missing'
        end
        puts "api-key = #{option(:api_key).gsub(/[123456789]/, '*')} symbols-file = #{options[:symbols_file]}"
      end

      def needs_key?
        false
      end

      def push_app
        puts "push_app #{TAG}"
        response = upload_app
        puts "Upload success!, check your build on #{response['build_url']}"
      end

      def android?
        option(:app_file).include? "apk"
      end


      private

      def upload_app
        uploadUrl = SERVER + UPLOAD_URL_PATH
        params = get_params
        post uploadUrl, params
      end

      def post url, params
        puts "Upload parameters = #{get_printable_params params} \nto #{url}"
        uri = URI.parse(url)
        request = Net::HTTP::Post::Multipart.new(uri.path, params, 'User-Agent' => "Travis plugin version=#{VERSION}")
        res = Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(request)
        end
        puts res.body
        resBody = JSON.parse(res.body)
        if (resBody['status'] == 'fail')
          raise Error, resBody['message']
        end
        return resBody
      end

      def get_printable_params params
        paramsToPrint = params.clone
        paramsToPrint['api_key'] = paramsToPrint['api_key'].gsub(/[123456789]/, '*')
        paramsToPrint['apk_file'] = paramsToPrint['apk_file'].path()
        JSON.pretty_generate(paramsToPrint)
      end

      def get_params
        params = {'api_key' => "#{option(:api_key)}"}
        add_file_param params, 'apk_file', option(:app_file)
        add_file_param params, 'symbols_file', options[:symbols_file]
        add_param params, 'video-quality', options[:video_quality]
        add_param params, 'screenshot-interval', options[:screenshot_interval]
        add_param params, 'max-duration', options[:max_duration]
        add_param params, 'testers-groups', options[:testers_groups]
        add_param params, 'metrics', options[:metrics]
        add_boolean_param params, 'data-only-wifi', options[:data_only_wifi]
        add_boolean_param params, 'record-on-background', options[:record_on_background]
        add_boolean_param params, 'video', options[:video]
        add_boolean_param params, 'notify', options[:notify]
        add_boolean_param params, 'auto-update', options[:auto_update]

        travisCommitRange = context.env.fetch('TRAVIS_COMMIT_RANGE',nil)
        if !travisCommitRange.nil?
          changelog = %x[git log  --pretty=oneline --abbrev-commit #{travisCommitRange}]
          add_param params, 'changelog', changelog
        end
        params
      end

      def add_file_param params, fileName, filePath
        if (!filePath.nil? && !filePath.empty?)
          params[fileName] = UploadIO.new(File.new(filePath), "", filePath.split("/").last)
        end
      end

      def add_param params, paramName, param
        if (!param.nil? && !param.empty?)
          params[paramName] = param
        end
      end

      def add_boolean_param params, paramName, param
        if (!param.nil?)
          params[paramName] = (param == true) ? "on" : "off"
        end
      end
    end
  end
end
