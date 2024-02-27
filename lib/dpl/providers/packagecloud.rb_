# talk to previous contributors about the logic in source_files
#
# the docs recommend to just `packagecloud push src target` https://packagecloud.io/docs#travis

module Dpl
  module Providers
    class Packagecloud < Provider
      register :packagecloud

      status :alpha

      description sq(<<-str)
        tbd
      str

      gem 'packagecloud-ruby', '~> 1.0.8', require: 'packagecloud'

      env :packagecloud

      opt '--username USER', 'The packagecloud.io username.', required: true
      opt '--token TOKEN', 'The packagecloud.io api token.', required: true, secret: true
      opt '--repository REPO', 'The repository to push to.', required: true
      opt '--local_dir DIR', 'The sub-directory of the built assets for deployment.', default: '.'
      opt '--dist DIST', 'Required for debian, rpm, and node.js packages (use "node" for node.js packages). The complete list of supported strings can be found on the packagecloud.io docs.'
      opt '--force', 'Whether package has to be (re)uploaded / deleted before upload'
      opt '--connect_timeout SEC', type: :integer, default: 60
      opt '--read_timeout SEC', type: :integer, default: 60
      opt '--write_timeout SEC', type: :integer, default: 180
      opt '--package_glob GLOB', type: :array, default: ['**/*']

      # previous implementation checks against all of these in dist_required? but
      # then the error message only lists rmp, deb, python, and dsc. i think the
      # error message might be out of date? so is the option description in the
      # readme (and thus above).
      NEED_DIST = %w(rpm deb dsc whl egg egg-info gz zip tar bz2 z tgz)

      msgs authenticate:       'Logging in to https://packagecloud.io with %{username}:%{token}',
           timeouts:           'Timeouts: %{timeout_info}',
           unauthenticated:    'Could not authenticate to https://packagecloud.io, please check the credentials',
           supported_packages: 'Supported packages: %s',
           source_packages:    'Source packages: %s',
           delete_package:     'Deleting package: %s on %s',
           push_package:       'Pushing package: %s to %s/%s',
           source_fragment:    'Found source fragment: %s for %s',
           missing_packages:   'No supported packages found',
           missing_dist:       'Distribution needed for rpm, deb, python, and dsc packages (e.g. dist: ubuntu/breezy)',
           unknown_dist:       'Failed to find distribution %{dist}',
           error:              'Error: %s'

      def install
        @cwd = Dir.pwd
        Dir.chdir(local_dir)
      end

      def login
        info :authenticate
        info :timeouts
        client
      rescue ::Packagecloud::UnauthenticatedException
        error :unauthenticated
      end

      def timeout_info
        to_pairs(timeouts)
      end

      def validate
        error :missing_packages if paths.empty?
        error :missing_dist if missing_dist?
        info :supported_packages, paths.join(', ')
        info :source_packages, source_paths.join(', ') if source_paths.any?
      end

      def deploy
        packages.each do |package|
          delete(package) if force?
          push(package)
        end
      end

      def finish
        Dir.chdir(@cwd)
      end

      private

        def delete(package)
          info :delete_package, package.filename, dist
          result = client.delete_package(repository, *dist.split('/'), package.filename)
          error "Error #{result.response}" unless result.succeeded
        end

        def push(package)
          info :push_package, package.filename, username, repository
          args = [repository, package]
          args << distro if dist_required?(package.filename)
          result = client.put_package(*args)
          error :error, result.response unless result.succeeded
        end

        def packages
          paths.map { |path| package(path) }
        end

        def package(path)
          opts = { file: path }
          opts[:source_files] = source_files(path) if source?(path)
          ::Packagecloud::Package.new(opts)
        end

        def paths
          @paths ||= glob(package_glob).select { |path| supported?(path) }
        end

        def source_paths
          paths.select { |path| source?(path) }
        end

        # I believe this resembles the logic in the previous version, but it seems
        # very odd to me. Files are considered source files only if they are already
        # part of the package (it looks up the package from the client, and extracts
        # the file names), and if they are not located in sub directories (it uses
        # File.basename to filter). Not sure that's how it's supposed to work?
        def source_files(path)
          files = contents(path)
          paths = glob('**/*').select { |path| files.include?(path) }
          paths = paths.map { |path| [File.basename(path), path] }
          paths.each { |name, _| info(:source_fragement, name, path) }
          paths.map { |name, path| [name, open(path)] }.to_h
        end

        def contents(path)
          package = ::Packagecloud::Package.new(file: path)
          result = client.package_contents(repository, package, distro)
          error :error, result.response unless result.succeeded
          result.response['files'].map { |file| file['filename'] }
        end

        def distro
          @distro ||= client.find_distribution_id(dist) || error(:unknown_dist)
        rescue ArgumentError => e
          error :error, e.message
        end

        def supported?(path)
          ::Packagecloud::SUPPORTED_EXTENSIONS.include?(ext(path))
        end

        def source?(path)
          ext(path) == 'dsc'
        end

        def dist_required?(path)
          NEED_DIST.include?(ext(path))
        end

        def package_glob
          "{#{super.join(',')}}"
        end

        def timeouts
          only(opts, :connect_timeout, :read_timeout, :write_timeout)
        end

        def ext(path)
          File.extname(path).to_s.gsub('.','').downcase
        end

        def glob(glob)
          Dir.glob(glob).reject { |path| File.directory?(path) }
        end

        def missing_dist?
          !dist? && paths.any? { |path| dist_required?(path) }
        end

        def client
          @client ||= ::Packagecloud::Client.new(credentials, "travis-ci dpl #{Dpl::VERSION}", connection)
        end

        def credentials
          ::Packagecloud::Credentials.new(username, token)
        end

        def connection
          ::Packagecloud::Connection.new('https', 'packagecloud.io', '443', timeouts)
        end

        def to_pairs(hash)
          hash.map { |pair| pair.join('=') }.join(' ')
        end
    end
  end
end
