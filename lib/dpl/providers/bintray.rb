# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'find'

module Dpl
  module Providers
    class Bintray < Provider
      register :bintray

      status :stable

      description sq(<<-STR)
        tbd
      STR

      gem 'json'

      env :bintray

      opt '--user USER', 'Bintray user', required: true
      opt '--key KEY', 'Bintray API key', required: true, secret: true
      opt '--file FILE', 'Path to a descriptor file for the Bintray upload', required: true
      opt '--passphrase PHRASE', 'Passphrase as configured on Bintray (if GPG signing is used)'
      opt '--url URL', default: 'https://api.bintray.com', internal: true

      msgs missing_file: 'Missing descriptor file: %{file}',
           invalid_file: 'Failed to parse descriptor file %{file}',
           create_package: 'Creating package %{package_name}',
           package_attrs: 'Adding attributes for package %{package_name}',
           create_version: 'Creating version %{version_name}',
           version_attrs: 'Adding attributes for version %{version_name}',
           upload_file: 'Uploading file %{source} to %{target}',
           sign_version: 'Signing version %s passphrase',
           publish_version: 'Publishing version %{version_name} of package %{package_name}',
           missing_path: 'Path: %{path} does not exist.',
           list_download: 'Listing %{path} in downloads',
           retrying: '%{code} response from Bintray. It may take some time for a version to be published, retrying in %{pause} sec ... (%{count}/%{max})',
           giveup_retries: 'Too many retries failed, giving up, something went wrong.',
           unexpected_code: 'Unexpected HTTP response code %s while checking if the %s exists',
           request_failed: '%s %s returned unexpected HTTP response code %s',
           request_success: 'Bintray response: %s %s. %s'

      PATHS = {
        packages: '/packages/%{subject}/%{repo}',
        package: '/packages/%{subject}/%{repo}/%{package_name}',
        package_attrs: '/packages/%{subject}/%{repo}/%{package_name}/attributes',
        versions: '/packages/%{subject}/%{repo}/%{package_name}/versions',
        version: '/packages/%{subject}/%{repo}/%{package_name}/versions/%{version_name}',
        version_attrs: '/packages/%{subject}/%{repo}/%{package_name}/versions/%{version_name}/attributes',
        version_sign: '/gpg/%{subject}/%{repo}/%{package_name}/versions/%{version_name}',
        version_publish: '/content/%{subject}/%{repo}/%{package_name}/%{version_name}/publish',
        version_file: '/content/%{subject}/%{repo}/%{package_name}/%{version_name}/%{target}',
        file_metadata: '/file_metadata/%{subject}/%{repo}/%{target}'
      }.freeze

      MAP = {
        package: %i[name desc licenses labels vcs_url website_url
                    issue_tracker_url public_download_numbers public_stats],
        version: %i[name desc released vcs_tag github_release_notes_file
                    github_use_tag_release_notes attributes]
      }.freeze

      def install
        require 'json'
      end

      def validate
        error :missing_file unless File.exist?(file)
        # validate that the repo exists, and we have access
      end

      def deploy
        create_package unless package_exists?
        create_version unless version_exists?
        upload_files
        sign_version if sign_version?
        publish_version && update_files if publish_version?
      end

      def package_exists?
        exists?(:package)
      end

      def create_package
        info :create_package
        post(path(:packages), compact(only(package, *MAP[:package])))
        return unless package_attrs

        info :package_attrs
        post(path(:package_attrs), package_attrs)
      end

      def version_exists?
        exists?(:version)
      end

      def create_version
        info :create_version
        post(path(:versions), compact(only(version, *MAP[:version])))
        return unless version_attrs

        info :version_attrs
        post(path(:version_attrs), version_attrs)
      end

      def upload_files
        files.each do |file|
          info :upload_file, source: file.source, target: file.target
          put(path(:version_file, target: file.target), file.read, file.params)
        end
      end

      def sign_version
        body = compact(passphrase: passphrase)
        info :sign_version, (passphrase? ? 'with' : 'without')
        post(path(:version_sign), body)
      end

      def publish_version
        info :publish_version
        post(path(:version_publish))
      end

      def update_files
        files.select(&:download).each do |file|
          info :list_download, path: file.target
          update_file(file)
        end
      end

      def update_file(file)
        retrying(max: 10, pause: 5) do
          body = { list_in_downloads: file.download }.to_json
          headers = { 'Content-Type': 'application/json' }
          put(path(:file_metadata, target: file.target), body, {}, headers)
        end
      end

      def retrying(opts)
        1.upto(opts[:max]) do |count|
          code = yield
          return if code < 400

          info :retrying, opts.merge(count: count, code: code)
          sleep opts[:pause]
        end
        error :giveup_retries
      end

      def files
        return {} unless files = descriptor[:files]
        return @files if @files

        keys = %i[path includePattern excludePattern uploadPattern matrixParams listInDownloads]
        files = files.map { |file| file if file[:path] = path_for(file[:includePattern]) }
        @files = files.compact.map { |file| find(*file.values_at(*keys)) }.flatten
      end

      def find(path, includes, excludes, uploads, params, download)
        paths = Find.find(path).select { |path| File.file?(path) }
        paths = paths.reject { |path| excluded?(path, excludes) }
        paths = paths.map { |path| [path, path.match(/#{includes}/)] }
        paths = paths.select(&:last)
        paths.map { |path, match| Upload.new(path, fmt(uploads, match.captures), params, download) }
      end

      def fmt(pattern, captures)
        captures.each.with_index.inject(pattern) do |pattern, (capture, ix)|
          pattern.gsub("$#{ix + 1}", capture)
        end
      end

      def excluded?(path, pattern)
        !pattern.to_s.empty? && path.match(/#{pattern}/)
      end

      def path_for(str)
        ix = str.index('(')
        path = ix.to_i.zero? ? str : str[0, ix]
        return path if File.exist?(path)

        warn(:missing_path, path: path)
        nil
      end

      def exists?(type)
        case code = head(path(type), raise: false, silent: true)
        when 200, 201 then true
        when 404 then false
        else error :unexpected_code, code, type
        end
      end

      def head(path, opts = {})
        req = Net::HTTP::Head.new(path)
        req.basic_auth(user, key)
        request(req, opts)
      end

      def post(path, body = nil)
        req = Net::HTTP::Post.new(path)
        req.add_field('Content-Type', 'application/json')
        req.basic_auth(user, key)
        req.body = JSON.dump(body) if body
        request(req)
      end

      def put(path, body, params = {}, headers = {})
        req = Net::HTTP::Put.new(append_params(path, params))
        headers.each { |key, value| req.add_field(key.to_s, value) }
        req.basic_auth(user, key)
        req.body = body
        request(req)
      end

      def request(req, opts = {})
        res = http.request(req)
        handle(req, res, opts)
        res.code.to_i
      end

      def http
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http
      end

      def append_params(path, params)
        [path, *Array(params).map { |pair| pair.join('=') }].join(';')
      end

      def handle(req, res, opts = { raise: true })
        error :request_failed, req.method, req.uri, res.code if opts[:raise] && !success?(res.code)
        info :request_success, res.code, res.message, parse(res)['message'] unless opts[:silent]
        res.code.to_i
      end

      def success?(code)
        code.to_s[0].to_i == 2
      end

      def descriptor
        @descriptor ||= symbolize(JSON.parse(File.read(file)))
      rescue StandardError
        error :invalid_file
      end

      def url
        @url ||= URI.parse(super || URL)
      end

      def package
        descriptor[:package]
      end

      def package_name
        package[:name]
      end

      def package_attrs
        package[:attributes]
      end

      def subject
        package[:subject]
      end

      def repo
        package[:repo]
      end

      def version
        descriptor[:version]
      end

      def version_name
        version[:name]
      end

      def version_attrs
        version[:attributes]
      end

      def sign_version?
        version[:gpgSign]
      end

      def publish_version?
        descriptor[:publish]
      end

      def path(resource, args = {})
        interpolate(PATHS[resource], args, secure: true)
      end

      def parse(json)
        hash = JSON.parse(json)
        hash.is_a?(Hash) ? hash : {}
      rescue StandardError
        {}
      end

      def compact(hash)
        hash.reject { |_, value| value.nil? }
      end

      def only(hash, *keys)
        hash.select { |key, _| keys.include?(key) }
      end

      class Upload < Struct.new(:source, :target, :params, :download)
        def read
          IO.read(source)
        end

        def eql?(other)
          source == other.source
        end
      end
    end
  end
end
