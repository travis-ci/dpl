require 'dpl/provider'

module DPL
  class Provider
    class CloudFiles < Provider
      requires 'fog'
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

        Dir.glob('**/*').each do |name|
          container.files.create(:key => name, :body => File.open(name)) unless File.directory?(name)
        end
      end
    end
  end
end
