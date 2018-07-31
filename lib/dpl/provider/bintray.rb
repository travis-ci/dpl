require 'json'
require 'net/http'
require "uri"
require 'find'

module DPL
  class Provider
    class Bintray < Provider
      DEFAULT_URL = 'https://api.bintray.com'

      def check_auth
        @user ||= option(:user)
        @key  ||= option(:key)
        @file ||= option(:file)
      end

      def needs_key?
        false
      end

      def url
        @url ||= URI.parse(options[:url] || DEFAULT_URL)
      end

      attr_accessor :test_mode
      attr_reader :user, :key, :file
      attr_reader :passphrase
      attr_reader :dry_run
      attr_reader :descriptor

      def initialize(*args)
        super(*args)
        @test_mode = false

        @passphrase = options[:passphrase]
        @dry_run = options[:dry_run]

        if @dry_run.nil?
          @dry_run = false
        end
      end

      def read_descriptor
        log "Reading descriptor file: #{file}"
        @descriptor = JSON.parse(File.read(file))
      end

      def descriptor=(json)
        @descriptor = JSON.parse(json)
      end

      def head_request(path)
        req = Net::HTTP::Head.new(path)
        req.basic_auth user, key

        sock = Net::HTTP.new(url.host, url.port)
        sock.use_ssl = true
        res = sock.start {|http| http.request(req) }

        return res
      end

      def post_request(path, body)
        req = Net::HTTP::Post.new(path)
        req.add_field('Content-Type', 'application/json')
        req.basic_auth user, key
        if !body.nil?
          req.body = body.to_json
        end

        sock = Net::HTTP.new(url.host, url.port)
        sock.use_ssl = true
        res = sock.start {|http| http.request(req) }
        return res
      end

      def put_file_request(local_file_path, upload_path, matrix_params)

        file = File.open(local_file_path, 'rb')
        data = file.read()
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        params = ''
        if !matrix_params.nil?
          matrix_params.each do |key, val|
            params << ";#{key}=#{val}"
          end
          upload_path << params
        end

        request = Net::HTTP::Put.new("#{upload_path}")
        request.basic_auth user, key
        request.body = data

        return http.request(request)
      end

      def upload_file(artifact)
        log "Uploading file '#{artifact.local_path}' to #{artifact.upload_path}"

        if dry_run
          return
        end

        package = descriptor["package"]
        version = descriptor["version"]
        package_name = package["name"]
        subject = package["subject"]
        repo = package["repo"]
        version_name = version["name"]

        path = "/content/#{subject}/#{repo}/#{package_name}/#{version_name}/#{artifact.upload_path}"
        res = put_file_request(artifact.local_path, path, artifact.matrix_params)
        log_bintray_response(res)
      end

      def package_exists_path
        package = descriptor["package"]
        subject = package["subject"]
        name = package["name"]
        repo = package["repo"]
        return "/packages/#{subject}/#{repo}/#{name}"
      end

      def package_exists?
        path = package_exists_path
        if !dry_run
          res = head_request(path)
          code = res.code.to_i
        else
          code = 404
        end

        if code == 404
          return false
        end
        if code == 201 || code == 200
          return true
        end
        name = descriptor["package"]["name"]
        abort("Unexpected HTTP response code #{code} returned from Bintray while checking if package '#{name}' exists. " +
                  "Response message: #{res.message}")
      end

      def version_exists_path
        package = descriptor["package"]
        version = descriptor["version"]
        package_name = package["name"]
        subject = package["subject"]
        repo = package["repo"]
        version_name = version["name"]

        return "/packages/#{subject}/#{repo}/#{package_name}/versions/#{version_name}"
      end

      def version_exists?
        path = version_exists_path
        if !dry_run
          res = head_request(path)
          code = res.code.to_i
        else
          code = 404
        end

        if code == 404
          return false
        end
        if code == 201 || code == 200
          return true
        end
        version_name = descriptor["version"]["name"]
        abort("Unexpected HTTP response code #{code} returned from Bintray while checking if version '#{version_name}' exists. " +
                  "Response message: #{res.message}")
      end

      def create_package
        package = descriptor["package"]
        repo = package["repo"]
        body = {}

        add_to_map(body, package, "name")
        add_to_map(body, package, "desc")
        add_to_map(body, package, "licenses")
        add_to_map(body, package, "labels")
        add_to_map(body, package, "vcs_url")
        add_to_map(body, package, "website_url")
        add_to_map(body, package, "issue_tracker_url")
        add_to_map(body, package, "public_download_numbers")
        add_to_map(body, package, "public_stats")

        subject = package["subject"]
        package_name = package["name"]
        log "Creating package '#{package_name}'..."

        path = "/packages/#{subject}/#{repo}"
        if !dry_run
          res = post_request(path, body)
          log_bintray_response(res)
          code = res.code.to_i
        else
          code = 200
        end

        if !test_mode
          if code == 201 || code == 200
            add_package_attributes
          end
        end
        RequestDetails.new(path, body)
      end

      def add_package_attributes
        package = descriptor["package"]
        repo = package["repo"]
        subject = package["subject"]
        package_name = package["name"]
        attributes = package["attributes"]
        path = nil
        if !attributes.nil?
          log "Adding attributes for package '#{package_name}'..."
          path = "/packages/#{subject}/#{repo}/#{package_name}/attributes"
          if !dry_run
            res = post_request(path, attributes)
            log_bintray_response(res)
          end
        end
        RequestDetails.new(path, attributes)
      end

      def create_version
        package = descriptor["package"]
        version = descriptor["version"]
        repo = package["repo"]
        body = {}

        add_to_map(body, version, "name")
        add_to_map(body, version, "desc")
        add_to_map(body, version, "released")
        add_to_map(body, version, "vcs_tag")
        add_to_map(body, version, "github_release_notes_file")
        add_to_map(body, version, "github_use_tag_release_notes")
        add_to_map(body, version, "attributes")

        package_name = package["name"]
        subject = package["subject"]
        version_name = version["name"]
        log "Creating version '#{version_name}'..."

        path = "/packages/#{subject}/#{repo}/#{package_name}/versions"
        if !dry_run
          res = post_request(path, body)
          log_bintray_response(res)
          code = res.code.to_i
        else
          code = 200
        end

        if !test_mode
          if code == 201 || code == 200
            add_version_attributes
          end
        end
        RequestDetails.new(path, body)
      end

      def add_version_attributes
        package = descriptor["package"]
        package_name = package["name"]
        subject = package["subject"]
        version = descriptor["version"]
        version_name = version["name"]
        repo = package["repo"]
        attributes = version["attributes"]
        path = nil
        if !attributes.nil?
          log "Adding attributes for version '#{version_name}'..."
          path = "/packages/#{subject}/#{repo}/#{package_name}/versions/#{version_name}/attributes"
          if !dry_run
            res = post_request(path, attributes)
            log_bintray_response(res)
          end
        end
        RequestDetails.new(path, attributes)
      end

      def check_and_create_package
        if !package_exists?
          create_package
        end
      end

      def check_and_create_version
        if !version_exists?
          create_version
        end
      end

      def upload_files
        files = files_to_upload

        files.each do |key, artifact|
          upload_file(artifact)
        end
      end

      def publish_version
        publish = descriptor["publish"]
        if publish
          package = descriptor["package"]
          version = descriptor["version"]
          repo = package["repo"]
          package_name = package["name"]
          subject = package["subject"]
          version_name = version["name"]

          log "Publishing version '#{version_name}' of package '#{package_name}'..."
          path = "/content/#{subject}/#{repo}/#{package_name}/#{version_name}/publish"
          if !dry_run
            res = post_request(path, nil)
            log_bintray_response(res)
          end
        end
        RequestDetails.new(path, nil)
      end

      def gpg_sign_version
        version = descriptor["version"]
        gpg_sign = version["gpgSign"]
        if gpg_sign
          package = descriptor["package"]
          repo = package["repo"]
          package_name = package["name"]
          subject = package["subject"]
          version_name = version["name"]

          body = nil
          if !passphrase.nil?
            log "Signing version with no passphrase..."
            body = {}
            body["passphrase"] = passphrase
          else
            log "Signing version with passphrase..."
          end

          path = "/gpg/#{subject}/#{repo}/#{package_name}/versions/#{version_name}"
          if !dry_run
            res = post_request(path, body)
            log_bintray_response(res)
          end
          RequestDetails.new(path, body)
        end
      end

      # Get the root path from which to start collecting files to be
      # uploaded to Bintray.
      def root_path(str)
        index = str.index('(')
        path = nil
        if index.nil? || str.start_with?('(')
          path = str
        else
          path = str[0, index]
        end

        if !test_mode && !File.exist?(path)
          log "Warning: Path: #{path} does not exist."
          return nil
        end
        return path
      end

      # Fills a map with Artifact objects which match
      # the include pattern and do not match the exclude pattern.
      # The artifacts are files collected from the file system.
      def fill_files_map(map, include_pattern, exclude_pattern, upload_pattern, matrix_params)
        # Get the root path from which to start collecting the files.
        root_path = root_path(include_pattern)
        if root_path.nil?
          return
        end

        # Start scanning the root path recursively.
        Find.find(root_path) do |path|
          add_if_matches(map, path, include_pattern, exclude_pattern, upload_pattern, matrix_params)
        end
      end

      def add_if_matches(map, path, include_pattern, exclude_pattern, upload_pattern, matrix_params)
        res = path.match(/#{include_pattern}/)

        # If the file matches the include pattern and it is not a directory.
        # In case test_mode is set, we do not check if the file exists.
        if !res.nil? && (test_mode || File.file?(path))
          # If the file does not match the exclude pattern.
          if exclude_pattern.nil? || exclude_pattern.empty? || !path.match(/#{exclude_pattern}/)
            # Using the capturing groups in the include pattern, replace the $1, $2, ...
            # in the upload pattern.
            groups = res.captures
            replaced_upload_pattern = upload_pattern
            for i in 0..groups.size-1
              replaced_upload_pattern = replaced_upload_pattern.gsub("$#{i+1}", groups[i])
            end
            map[path] = Artifact.new(path, replaced_upload_pattern, matrix_params)
          end
        end
      end

      # Returns a map containing Artifact objects.
      # The map contains the files to be uploaded to Bintray.
      def files_to_upload
        upload_files = Hash.new()
        files = descriptor["files"]
        if files.nil?
          return upload_files
        end

        files.each { |patterns|
          fill_files_map(
              upload_files,
              patterns["includePattern"],
              patterns["excludePattern"],
              patterns["uploadPattern"],
              patterns["matrixParams"])
        }

        return upload_files
      end

      def push_app
        read_descriptor
        check_and_create_package
        check_and_create_version
        upload_files
        gpg_sign_version
        publish_version
      end

      # Copies a key from one map to another, if the key exists there.
      def add_to_map(to_map, from_map, key)
        if !from_map[key].nil?
          to_map[key] = from_map[key]
        end
      end

      def log_bintray_response(res)
        msg = ''
        if !res.body.nil?
          begin
            response = JSON.parse(res.body)
            msg = response["message"]
          rescue
          end
        end

        log "Bintray response: #{res.code.to_i} #{res.message}. #{msg}"
      end

      def log(msg)
        puts "[Bintray Upload] #{msg}"
      end

      # This class represents an artifact (file) to be uploaded to Bintray.
      class Artifact
        def initialize(local_path, upload_path, matrix_params)
          @local_path = local_path
          @upload_path = upload_path
          @matrix_params = matrix_params
        end

        def hash
          return @localPath.hash
        end

        def eql?(other)
          @localPath == other.local_path
        end

        attr_reader :local_path
        attr_reader :upload_path
        attr_reader :matrix_params
      end

      # Used to return the path and body of REST requests sent to Bintray.
      # Used for testing.
      class RequestDetails
        def initialize(path, body)
          @path = path
          @body = body
        end

        attr_reader :path
        attr_reader :body
      end
    end
  end
end
