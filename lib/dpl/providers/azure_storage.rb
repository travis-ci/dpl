module Dpl
  module Providers
    class AzureStorage < Provider
      status :dev

      full_name 'Azure Storage'

      description sq(<<-str)
        tbd
      str

      gem 'azure-storage-blob', '~> 1.1.0', require: 'azure/storage/blob'

      env 'azure_storage'

      opt '--account NAME',   'Storage account name', required: true
      opt '--access_key KEY', 'Storage account access key', required: true, secret: true
      opt '--container NAME', 'Storage container name', default: '$web'
      opt '--local_dir DIR',  'Local directory to upload from', default: '.', example: '~/travis/build (absolute path) or ./build (relative path)'
      opt '--glob GLOB',      'Paths to upload', default: '**/*'
      opt '--dot_match',      'Upload hidden files starting with a dot'

      msgs login:  'Logging in to account %{account} with access key %{access_key}',
           upload: 'Uploading %{path} to %{container}'

      def login
        info :login
        client
      end

      def prepare
        Dir.chdir(local_dir)
      end

      def deploy
        files.each do |path|
          upload(path)
        end
      end

      private

        def upload(path)
          info :upload, path: path
          content = File.open(path, 'rb', &:read)
          client.create_block_blob(container, path, content)
        end

        def files
          Dir.glob(*glob).select { |path| File.file?(path) }
        end

        def glob
          glob = [super]
          glob << File::FNM_DOTMATCH if dot_match?
          glob
        end

        def client
          @client ||= Azure::Storage::Blob::BlobService.create(
            storage_account_name: account,
            storage_access_key: access_key
          )
        end
    end
  end
end
