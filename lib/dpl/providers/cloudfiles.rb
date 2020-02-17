module Dpl
  module Providers
    class Cloudfiles < Provider
      register :cloudfiles

      status :alpha

      full_name 'Cloud Files'

      description sq(<<-str)
        tbd
      str

      gem 'nokogiri', '< 1.10'
      gem 'fog-core', '= 2.1.0', require: 'fog/core'
      gem 'fog-rackspace', '~> 0.1.6', require: 'fog/rackspace'

      env :cloudfiles

      opt '--username USER',  'Rackspace username', required: true
      opt '--api_key KEY',    'Rackspace API key', required: true, secret: true
      opt '--region REGION',  'Cloudfiles region', required: true, enum: %w(ord dfw syd iad hkg)
      opt '--container NAME', 'Name of the container that files will be uploaded to', required: true
      opt '--glob GLOB',      'Paths to upload', default: '**/*'
      opt '--dot_match',      'Upload hidden files starting a dot'

      msgs missing_container: 'The specified container does not exist.'

      def deploy
        paths.each do |path|
          container.files.create(key: path, body: File.open(path))
        end
      end

      def paths
        paths = Dir.glob(*glob)
        paths.reject { |path| File.directory?(path) }
      end

      def glob
        glob = [super]
        glob << File::FNM_DOTMATCH if dot_match?
        glob
      end

      def container
        @container ||= api.directories.get(super) || error(:missing_container)
      end

      def api
        @api ||= Fog::Storage.new(
          provider: 'Rackspace',
          rackspace_username: username,
          rackspace_api_key: api_key,
          rackspace_region: region
        )
      end
    end
  end
end
