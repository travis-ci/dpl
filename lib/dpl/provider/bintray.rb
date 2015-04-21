module DPL
  class Provider
    class Bintray < Provider

      @@file
      @@user
      @@key
      @@url
      @@descriptor

      def check_auth
      end

      def needs_key?
        false
      end

      def initFromArgs
        @@user = options[:user]
        @@key = options[:key]
        @@url = options[:url]
        @@file = options[:file]

        if @@user.nil?
          abort("The 'user' argument is required")
        end
        if @@key.nil?
          abort("The 'key' argument is required")
        end
        if @@file.nil?
          abort("The 'file' argument is required")
        end
        if @@url.nil?
          @@url = 'https://api.bintray.com'
        end
      end

      def readDescriptor
        log "Reading descriptor file: #{@@file}"
        file = File.open(@@file)
        content = ""
        file.each {|line|
          content << line
        }

        require 'json'
        @@descriptor = JSON.parse(content)
      end

      def headRequest(path)
        url = URI.parse(@@url)
        req = Net::HTTP::Head.new(path)
        req.basic_auth @@user, @@key

        sock = Net::HTTP.new(url.host, url.port)
        sock.use_ssl = true
        res = sock.start {|http| http.request(req) }

        return res
      end

      def postRequest(path, body)
        req = Net::HTTP::Post.new(path)
        req.add_field('Content-Type', 'application/json')
        req.basic_auth @@user, @@key
        req.body = body.to_json

        url = URI.parse(@@url)
        sock = Net::HTTP.new(url.host, url.port)
        sock.use_ssl = true
        res = sock.start {|http| http.request(req) }
        return res
      end

      def putRequest(path)
        url = URI.parse(@@url)
        req = Net::HTTP::Put.new(path)
        req.basic_auth @@user, @@key

        sock = Net::HTTP.new(url.host, url.port)
        sock.use_ssl = true
        res = sock.start {|http| http.request(req) }

        return res
      end

      def putBinaryFileRequest(localFilePath, uploadPath)
        require 'net/http'
        require "uri"

        url = URI.parse(@@url)

        data = File.read(localFilePath)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Put.new(uploadPath)
        request.basic_auth @@user, @@key
        request.body = data

        return http.request(request)
      end

      def uploadFile(localPath, uploadPath)
        log "Uploading file '#{localPath}' to '#{uploadPath}'..."

        package = @@descriptor["package"]
        version = @@descriptor["version"]
        packageName = package["name"]
        repo = package["repo"]
        versionName = version["name"]

        path = path = "/content/#{@@user}/#{repo}/#{packageName}/#{versionName}/#{uploadPath}"
        res = putBinaryFileRequest(localPath, path)
        logBintrayResponse(res)
      end

      def packageExists
        package = @@descriptor["package"]
        name = package["name"]
        repo = package["repo"]
        path = "/packages/#{@@user}/#{repo}/#{name}"
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
        package = @@descriptor["package"]
        version = @@descriptor["version"]
        packageName = package["name"]
        repo = package["repo"]
        versionName = version["name"]

        path = "/packages/#{@@user}/#{repo}/#{packageName}/versions/#{versionName}"
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
        package = @@descriptor["package"]
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

        packageName = package["name"]
        log "Creating package '#{packageName}'..."
        res = postRequest("/packages/#{@@user}/#{repo}", body)
        logBintrayResponse(res)

        code = res.code.to_i
        if code == 201 || code == 200
          attributes = package["attributes"]
          if !attributes.nil?
            log "Adding attributes for package '#{packageName}'..."
            res = postRequest("/packages/#{@@user}/#{repo}/#{packageName}/attributes", attributes)
            logBintrayResponse(res)
          end
        end
      end

      def createVersion
        package = @@descriptor["package"]
        version = @@descriptor["version"]
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
        versionName = version["name"]
        log "Creating version '#{versionName}'..."

        res = postRequest("/packages/#{@@user}/#{repo}/#{packageName}/versions", body)
        logBintrayResponse(res)

        code = res.code.to_i
        if code == 201 || code == 200
          attributes = package["attributes"]
          if !attributes.nil?
            log "Adding attributes for version '#{versionName}'..."
            res = postRequest("/packages/#{@@user}/#{repo}/#{packageName}/versions/#{versionName}/attributes", attributes)
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

        # uploadFile("C:/temp/5/hola/hola-0.0.0.gem", "a/b/c/d/hola-0.0.0.gem")
      end

      def deploy
        require 'net/http'
        require 'net/https'
        require 'uri'

        initFromArgs
        log "Deploying to Bintray..."
        readDescriptor
        checkAndCreatePackage
        checkAndCreateVersion
        uploadFiles
      end

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
    end
  end
end