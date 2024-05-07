# frozen_string_literal: true

require 'dpl/version'
require 'net/http'
require 'securerandom'

module Dpl
  module Providers
    class Testfairy < Provider
      register :testfairy

      status :alpha

      full_name 'TestFairy'

      description sq(<<-STR)
        tbd
      STR

      gem 'json'
      gem 'multipart-post', '~> 2.0.0', require: 'net/http/post/multipart'

      env :testfairy

      opt '--api_key KEY', 'TestFairy API key', required: true, secret: true
      opt '--app_file FILE', 'Path to the app file that will be generated after the build (APK/IPA)', required: true
      opt '--symbols_file FILE', 'Path to the symbols file'
      opt '--testers_groups GROUPS', 'Tester groups to be notified about this build', example: 'e.g. group1,group1'
      opt '--notify', 'Send an email with a changelog to your users'
      opt '--auto_update', 'Automaticall upgrade all the previous installations of this app this version'
      opt '--advanced_options OPTS', 'Comma_separated list of advanced options', example: 'option1,option2'

      URL = 'https://upload.testfairy.com/api/upload'
      UA  = "Travis CI dpl version=#{Dpl::VERSION}".freeze

      msgs deploy: 'Uploading to TestFairy: %s',
           done: 'Done. Check your build at %s'

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
          'testers-groups': testers_groups,
          'notify': bool(notify),
          'auto-update': bool(auto_update),
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
        Net::HTTP.start(uri.host, uri.port, use_ssl: true)
      end

      def uri
        @uri ||= URI.parse(URL)
      end

      def file(path)
        UploadIO.new(path, '', File.basename(path)) if path
      end

      def bool(obj)
        unless obj.nil?
          obj ? 'on' : 'off'
        end
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
