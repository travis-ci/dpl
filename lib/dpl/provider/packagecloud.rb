module DPL
  class Provider
    class Packagecloud < Provider
      requires 'packagecloud-ruby', :version => "0.2.17", :load => 'packagecloud'

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
        ["rpm", "deb", "dsc"].include?(ext)
      end

      def error_if_dist_required(filename)
        ext = File.extname(filename).gsub!('.','')
        if dist_required?(ext) && @dist.nil?
          error "Distribution needed for rpm, deb, and dsc packages, example --dist='ubuntu/breezy'"
        end
      end

      def is_source_package?(filename)
        ext = File.extname(filename).gsub!('.','')
        ext == 'dsc'
      end

      def get_source_files_for(orig_filename)
        source_files = {}
        glob_args = ["**/*"]
        package = ::Packagecloud::Package.new(open(orig_filename))
        result = @client.package_contents(@repo, package)
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
        packages = []
        glob_args = Array(options.fetch(:package_glob, '**/*'))
        Dir.chdir(options.fetch(:local_dir, Dir.pwd)) do
          Dir.glob(*glob_args) do |filename|
            unless File.directory?(filename)
              if is_supported_package?(filename)
                error_if_dist_required(filename)
                log "Detected supported package: #{filename}"
                if dist_required?(filename)
                  if is_source_package?(filename)
                    log "Processing source package: #{filename}"
                    source_files = get_source_files_for(filename)
                    packages << ::Packagecloud::Package.new(open(filename), get_distro(@dist), source_files, filename)
                  else
                    packages << ::Packagecloud::Package.new(open(filename), get_distro(@dist), {}, filename)
                  end
                else
                  packages << ::Packagecloud::Package.new(open(filename), nil, {}, filename)
                end
              end
            end
          end
        end

        packages.each do |package|
          result = @client.put_package(@repo, package)
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
