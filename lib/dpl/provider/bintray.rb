require 'json'
require 'net/http'
require "uri"
require 'find'

module DPL
  class Provider
    class Bintray < Provider

      @file
      @user
      @key
      @passphrase
      @url
      @descriptor

      def check_auth
      end

      def needs_key?
        false
      end

      def initFromArgs
        @user = options[:user]
        @key = options[:key]
        @url = options[:url]
        @file = options[:file]
        @passphrase = options[:passphrase]

        if @user.nil?
          abort("The 'user' argument is required")
        end
        if @key.nil?
          abort("The 'key' argument is required")
        end
        if @file.nil?
          abort("The 'file' argument is required")
        end
        if @url.nil?
          @url = 'https://api.bintray.com'
        end
      end

      def readDescriptor
        log "Reading descriptor file: #{@file}"
        file = File.open(@file)
        content = ""
        file.each {|line|
          content << line
        }

        @descriptor = JSON.parse(content)
      end

      def headRequest(path)
        url = URI.parse(@url)
        req = Net::HTTP::Head.new(path)
        req.basic_auth @user, @key

        sock = Net::HTTP.new(url.host, url.port)
        sock.use_ssl = true
        res = sock.start {|http| http.request(req) }

        return res
      end

      def postRequest(path, body)
        req = Net::HTTP::Post.new(path)
        req.add_field('Content-Type', 'application/json')
        req.basic_auth @user, @key
        if !body.nil?
          req.body = body.to_json
        end

        url = URI.parse(@url)
        sock = Net::HTTP.new(url.host, url.port)
        sock.use_ssl = true
        res = sock.start {|http| http.request(req) }
        return res
      end

      def putRequest(path)
        url = URI.parse(@url)
        req = Net::HTTP::Put.new(path)
        req.basic_auth @user, @key

        sock = Net::HTTP.new(url.host, url.port)
        sock.use_ssl = true
        res = sock.start {|http| http.request(req) }

        return res
      end

      def putBinaryFileRequest(localFilePath, uploadPath)
        url = URI.parse(@url)

        data = File.read(localFilePath)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Put.new(uploadPath)
        request.basic_auth @user, @key
        request.body = data

        return http.request(request)
      end

      def uploadFile(artifact)
        log "Uploading file '#{artifact.getLocalPath}' to #{artifact.getUploadPath}"

        package = @descriptor["package"]
        version = @descriptor["version"]
        packageName = package["name"]
        subject = package["subject"]
        repo = package["repo"]
        versionName = version["name"]

        path = "/content/#{subject}/#{repo}/#{packageName}/#{versionName}/#{artifact.getUploadPath}"
        res = putBinaryFileRequest(artifact.getLocalPath, path)
        logBintrayResponse(res)
      end

      def packageExists
        package = @descriptor["package"]
        name = package["name"]
        subject = package["subject"]
        repo = package["repo"]
        path = "/packages/#{subject}/#{repo}/#{name}"
        res = headRequest(path)
        code = res.code.to_i

        if code == 404
          return false
        end
        if code == 201 || code == 200
          return true
        end
        abort("Unexpected HTTP response code #{code} returned from Bintray while checking if package '#{name}' exists. " +
          "Response message: #{res.message}")
      end

      def versionExists
        package = @descriptor["package"]
        version = @descriptor["version"]
        packageName = package["name"]
        subject = package["subject"]
        repo = package["repo"]
        versionName = version["name"]

        path = "/packages/#{subject}/#{repo}/#{packageName}/versions/#{versionName}"
        res = headRequest(path)
        code = res.code.to_i

        if code == 404
          return false
        end
        if code == 201 || code == 200
          return true
        end
        abort("Unexpected HTTP response code #{code} returned from Bintray while checking if version '#{versionName}' exists. " +
          "Response message: #{res.message}")
      end

      def createPackage
        package = @descriptor["package"]
        repo = package["repo"]
        body = {}

        addToMap(body, package, "name")
        addToMap(body, package, "desc")
        addToMap(body, package, "licenses")
        addToMap(body, package, "labels")
        addToMap(body, package, "vcs_url")
        addToMap(body, package, "website_url")
        addToMap(body, package, "issue_tracker_url")
        addToMap(body, package, "public_download_numbers")
        addToMap(body, package, "public_stats")

        subject = package["subject"]
        packageName = package["name"]
        log "Creating package '#{packageName}'..."
        res = postRequest("/packages/#{subject}/#{repo}", body)
        logBintrayResponse(res)

        code = res.code.to_i
        if code == 201 || code == 200
          attributes = package["attributes"]
          if !attributes.nil?
            log "Adding attributes for package '#{packageName}'..."
            res = postRequest("/packages/#{subject}/#{repo}/#{packageName}/attributes", attributes)
            logBintrayResponse(res)
          end
        end
      end

      def createVersion
        package = @descriptor["package"]
        version = @descriptor["version"]
        repo = package["repo"]
        body = {}

        addToMap(body, version, "name")
        addToMap(body, version, "desc")
        addToMap(body, version, "released")
        addToMap(body, version, "vcs_tag")
        addToMap(body, version, "github_release_notes_file")
        addToMap(body, version, "github_use_tag_release_notes")
        addToMap(body, version, "attributes")

        packageName = package["name"]
        subject = package["subject"]
        versionName = version["name"]
        log "Creating version '#{versionName}'..."

        res = postRequest("/packages/#{subject}/#{repo}/#{packageName}/versions", body)
        logBintrayResponse(res)

        code = res.code.to_i
        if code == 201 || code == 200
          attributes = package["attributes"]
          if !attributes.nil?
            log "Adding attributes for version '#{versionName}'..."
            res = postRequest("/packages/#{subject}/#{repo}/#{packageName}/versions/#{versionName}/attributes", attributes)
            logBintrayResponse(res)
          end
        end
      end

      def checkAndCreatePackage
        if !packageExists
          createPackage
        end
      end

      def checkAndCreateVersion
        if !versionExists
          createVersion
        end
      end

      def uploadFiles
        files = getFilesToUpload

        files.each do |key, artifact|
          uploadFile(artifact)
        end
      end

      def publishVersion
        publish = @descriptor["publish"]
        if publish
          package = @descriptor["package"]
          version = @descriptor["version"]
          repo = package["repo"]
          packageName = package["name"]
          subject = package["subject"]
          versionName = version["name"]

          log "Publishing version '#{versionName}' of package '#{packageName}'..."
          res = postRequest("/content/#{subject}/#{repo}/#{packageName}/#{versionName}/publish", nil)
          logBintrayResponse(res)
        end
      end

      def gpgSignVersion
        version = @descriptor["version"]
        gpgSign = version["name"]
        if gpgSign
          package = @descriptor["package"]
          repo = package["repo"]
          packageName = package["name"]
          subject = package["subject"]
          versionName = version["name"]

          log "Signing version..."
          body = nil
          if !@passphrase.nil?
            body = {}
            body["passphrase"] = @passphrase
          end

          res = postRequest("/gpg/#{subject}/#{repo}/#{packageName}/versions/#{versionName}", body)
          logBintrayResponse(res)
        end
      end

      # Get the root path from which to start collecting files to be
      # uploaded to Bintray.
      def getRootPath(str)
        index = str.index('(')
        path = nil
        if index.nil?
          path = str
        else
          path = str[0, index]
        end

        if !File.exist?(path)
          log "Warning: Path: #{path} does not exist."
          return nil
        end
        return path
      end

      # Fills a map with Artifact objects which match
      # the include pattern and do not match the exclude pattern.
      # The artifacts are files collected from the file system.
      def fillFilesMap(map, includePattern, excludePattern, uploadPattern)
        # Get the root path from which to start collecting the files.
        rootPath = getRootPath(includePattern)
        if rootPath.nil?
          return
        end

        # Start scanning the root path recursively.
        Find.find(rootPath) do |path|
          res = path.match(/#{includePattern}/)
          # If the file matches the include pattern and it is not a directory.
          if !res.nil? && File.file?(path)
            # If the file does not match the exclude pattern.
            if excludePattern.nil? || excludePattern.empty? || !path.match(/#{excludePattern}/)
              # Using the capturing groups in the include pattern, replace the $1, $2, ...
              # in the upload pattern.
              groups = res.captures
              replacedUploadPattern = uploadPattern
              for i in 0..groups.size-1
                replacedUploadPattern = replacedUploadPattern.gsub("$#{i+1}", groups[i])
              end
              map[path] = Artifact.new(path, replacedUploadPattern)
            end
          end
        end
      end

      # Returns a map containing Artifact objects.
      # The map contains the files to be uploaded to Bintray.
      def getFilesToUpload
        filesToUpload = Hash.new()
        files = @descriptor["files"]
        if files.nil?
          return filesToUpload
        end

        files.each { |patterns|
          fillFilesMap(
              filesToUpload,
              patterns["includePattern"],
              patterns["excludePattern"],
              patterns["uploadPattern"])
        }

        return filesToUpload
      end

      def deploy
        initFromArgs
        readDescriptor
        checkAndCreatePackage
        checkAndCreateVersion
        uploadFiles
        gpgSignVersion
        publishVersion
      end

      # Copies a key from one map to another, if the key exists there.
      def addToMap(toMap, fromMap, key)
        if !fromMap[key].nil?
          toMap[key] = fromMap[key]
        end
      end

      def logBintrayResponse(res)
        msg = ""
        if !res.body.nil?
          response = JSON.parse(res.body)
          begin
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
        @localPath = nil
        @uploadPath = nil

        def initialize(localPath, uploadPath)
          @localPath = localPath
          @uploadPath = uploadPath
        end

        def hash
          return @localPath.hash
        end

        def eql?(other)
          @localPath == other.getLocalPath
        end

        def getLocalPath
          return @localPath
        end

        def getUploadPath
          return @uploadPath
        end
      end
    end
  end
end