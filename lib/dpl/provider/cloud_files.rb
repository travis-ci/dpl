require 'dpl/provider'
require 'fog/rackspace'

module DPL
  class Provider
    class CloudFiles < Provider
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
