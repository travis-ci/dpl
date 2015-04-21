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

      def packageExists
        packageName = @@descriptor["package"]["name"]
        path = "/packages/#{@@user}/maven/#{packageName}"
        res = headRequest(path)
        code = res.code.to_i

        if code == 404
          return false
        end
        if code == 201 || code == 200
          return true
        end
        abort("Unexpected HTTP response code #{code} returned from Bintray while checking if package '#{package}' exists. " +
          "Response message: #{res.message}")
      end

      def createPackage
        package = @@descriptor["package"]
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
        res = postRequest("/packages/#{@@user}/maven", body)
        log "Bintray response: #{res.code.to_i} #{res.message}"

        attributes = package["attributes"]
        if !attributes.nil?
          log "Adding attributes for package '#{packageName}'..."
          res = postRequest("/packages/#{@@user}/maven/#{packageName}/attributes", attributes)
          log "Bintray response: #{res.code.to_i} #{res.message}"
        end
      end

      def checkAndCreatePackage
        if !packageExists
          createPackage
        end
      end

      def deploy
        require 'net/http'
        require 'net/https'
        require 'uri'

        initFromArgs
        log "Deploying to Bintray..."
        readDescriptor

        checkAndCreatePackage
      end

      def addToMap(toMap, fromMap, key)
        if !fromMap[key].nil?
          toMap[key] = fromMap[key]
        end
      end

      def log(msg)
        puts "[Bintray Upload] #{msg}"
      end
    end
  end
end