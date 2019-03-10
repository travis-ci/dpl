require 'azure/storage/blob'

module DPL
  class Provider
    class AzureStorage < Provider
      def needs_key?
        false
      end

      def client
        @client ||= Azure::Storage::Blob::BlobService.create(
          storage_account_name: option(:account_name),
          storage_access_key: option(:account_key)
        )
      end

      def check_auth
        log "Logging in Account:#{option(:account_name)}"
      end

      def push_app
        glob_args = ["**/*"]
        glob_args << File::FNM_DOTMATCH if options[:dot_match]
        Dir.chdir(options.fetch(:local_dir, Dir.pwd)) do
          Dir.glob(*glob_args) do |filename|
            next if File.directory?(filename)
            content = File.open(filename, 'rb', &:read)
            # To host static web, we always use container named '$web'
            client.create_block_blob('$web', filename, content)
          end
        end
      end
    end
  end
end
