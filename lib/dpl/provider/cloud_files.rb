require 'dpl/provider'

module DPL
  class Provider
    class CloudFiles < Provider
      requires 'net-ssh',    load: 'net/ssh',    version: '~> 2.9.2' # Anything higher requires Ruby 2.x
      requires 'mime-types', load: 'mime/types', version: '~> 2.6.2' # Anything higher requires Ruby 2.x
      requires 'nokogiri', version: '~> 1.6.8.1' # 1.7.0 and up requires Ruby 2.1.0 (via fog-xml)
      requires 'fog-rackspace', load: 'fog/rackspace'
      experimental 'Rackspace Cloud Files'

      def needs_key?
        false
      end

      def api
        @api ||= Fog::Storage.new(:provider => 'Rackspace', :rackspace_username => option(:username), :rackspace_api_key => option(:api_key), :rackspace_region => option(:region))
      end

      def check_auth
        log "Authenticated as #{option(:username)}"
      end

      def push_app
        container = api.directories.get(option(:container))

        raise Error, 'The specified container does not exist.' if container.nil?

        glob_args = ['**/*']
        glob_args << File::FNM_DOTMATCH if options[:dot_match]

        Dir.glob(*glob_args).each do |name|
          container.files.create(:key => name, :body => File.open(name)) unless File.directory?(name)
        end
      end
    end
  end
end
