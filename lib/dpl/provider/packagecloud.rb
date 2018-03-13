require 'packagecloud'

module DPL
  class Provider
    class Packagecloud < Provider
      def check_auth
        setup_auth
        begin
          @client = ::Packagecloud::Client.new(@creds, "travis-ci")
        rescue ::Packagecloud::UnauthenticatedException
          error "Could not authenticate to https://packagecloud.io, please check credentials"
        end
      end

      def needs_key?
        false
      end

      def setup_auth
        @username = option(:username)
        @token = option(:token)
        @repo = option(:repository)
        @dist = option(:dist) if options[:dist]
        @creds = ::Packagecloud::Credentials.new(@username, @token)
        log "Logging into https://packagecloud.io with #{@username}:#{@token[-4..-1].rjust(20, '*')}"
      end

      def get_distro(query)
        distro = nil
        begin
          distro = @client.find_distribution_id(query)
        rescue ArgumentError => exception
          error "Error: #{exception.message}"
        end
        if distro.nil?
          error "Could not find distribution named #{query}"
        end
        distro
      end

      def is_supported_package?(filename)
        ext = File.extname(filename).gsub!('.','')
        ::Packagecloud::SUPPORTED_EXTENSIONS.include?(ext)
      end

      def dist_required?(filename)
        ext = File.extname(filename).gsub!('.','')
        if ext.nil?
          error "filename: #{filename} has no extension!"
        end
        ["rpm", "deb", "dsc", "whl", "egg", "egg-info", "gz", "zip", "tar", "bz2", "z", "tgz"].include?(ext.downcase)
      end

      def error_if_dist_required(filename)
        if dist_required?(filename) && @dist.nil?
          error "Distribution needed for rpm, deb, python, and dsc packages, example --dist='ubuntu/breezy'"
        end
      end

      def is_source_package?(filename)
        ext = File.extname(filename).gsub!('.','')
        ext == 'dsc'
      end

      def get_source_files_for(orig_filename)
        source_files = {}
        glob_args = ["**/*"]
        package = ::Packagecloud::Package.new(:file => orig_filename)
        result = @client.package_contents(@repo, package, get_distro(@dist))
        if result.succeeded
          package_contents_files = result.response["files"].map { |x| x["filename"] }
          Dir.chdir(options.fetch(:local_dir, Dir.pwd)) do
            Dir.glob(*glob_args) do |filename|
              unless File.directory?(filename)
                basename = File.basename(filename)
                if package_contents_files.include?(basename)
                  log "Found source fragment: #{basename} for #{orig_filename}"
                  source_files = source_files.merge({basename => open(filename)})
                end
              end
            end
          end
        else
          error "Error: #{result.response}"
        end
        source_files
      end

      def push_app
        forced = options.fetch(:force, nil)
        packages = []
        glob_args = Array(options.fetch(:package_glob, '**/*'))
        Dir.chdir(options.fetch(:local_dir, Dir.pwd)) do
          Dir.glob(*glob_args) do |filename|
            unless File.directory?(filename)
              if is_supported_package?(filename)
                log "Detected supported package: #{filename}"
                error_if_dist_required(filename)
                if is_source_package?(filename)
                  log "Processing source package: #{filename}"
                  source_files = get_source_files_for(filename)
                  packages << ::Packagecloud::Package.new(:file => filename, :source_files => source_files)
                else
                  packages << ::Packagecloud::Package.new(:file => filename)
                end
              end
            end
          end
        end

        packages.each do |package|
          if forced
            log "Deleting package: #{package.filename}"
            distro, distro_release = @dist.split("/")
            result = @client.delete_package(@repo, distro, distro_release, package.filename)
            if result.succeeded
              log "Successfully deleted #{package.filename} on #{@dist}"
            else
              error "Error #{result.response}"
            end
          end
          log "Pushing package: #{package.filename}"
          if dist_required?(package.filename)
            result = @client.put_package(@repo, package, get_distro(@dist))
          else
            result = @client.put_package(@repo, package)
          end

          if result.succeeded
            log "Successfully pushed #{package.filename} to #{@username}/#{@repo}"
          else
            error "Error #{result.response}"
          end
        end
        if packages.empty?
          error "Error: No supported packages found! Perhaps try skip_cleanup: true"
        end
      end

    end

  end
end
