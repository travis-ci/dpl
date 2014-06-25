require 'kconv'

module DPL
  class Provider
    class GCS < Provider
      requires 'gstore'
      experimental 'Google Cloud Storage'

      def needs_key?
        false
      end

      def client
        @client ||= GStore::Client.new(
          :access_key => option(:access_key_id),
          :secret_key => option(:secret_access_key)
        )
      end

      def check_auth
        log "Logging in with Access Key: #{option(:access_key_id)[-4..-1].rjust(20, '*')}"
      end

      def push_app
        glob_args = ["**/*"]
        glob_args << File::FNM_DOTMATCH if options[:dot_match]
        Dir.chdir(options.fetch(:local_dir, Dir.pwd)) do
          Dir.glob(*glob_args) do |filename|
            next if File.directory?(filename)

            log "Push: #{filename}"

            client.put_object(
              option(:bucket),
              filename,
              :data => File.read(filename)
            )
          end
        end
      end

    end
  end
end
