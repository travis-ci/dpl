require 'kconv'
require 'google/cloud/storage'

module DPL
  class Provider
    class GCS < Provider
      def needs_key?
        false
      end

      def client
        @client ||= Google::Cloud::Storage.new(
          project_id: option(:project_id),
          credentials: option(:credentials)
        )
      rescue
        error "Unable to initialize GCS API client. Please check your project_id and credentials file"
      end

      def check_auth
        client && client.bucket(option(:bucket))
      end

      def check_app
      end

      def upload_path(filename)
        [options[:upload_dir], filename].compact.join("/")
      end

      def push_app
        glob_args = ["**/*"]
        glob_args << File::FNM_DOTMATCH if options[:dot_match]
        Dir.chdir(options.fetch(:local_dir, Dir.pwd)) do
          Dir.glob(*glob_args) do |filename|
            next if File.directory?(filename)
            opts = {}
            opts[:acl] = options[:acl] if options[:acl]

            bucket = client.bucket(option(:bucket))
            local_file = bucket.file(filename)

            file.copy bucket, file.name, opts
          end
        end
      end

      private
      def encoding_option_for(path)
        if detect_encoding? && encoding_for(path)
          {"Content-Encoding" => encoding_for(path)}
        else
          {}
        end
      end

    end
  end
end
