require 'json'

module DPL
  class Provider
    class QingStor < Provider
      requires 'qingstor-sdk', version: '= 1.9.3', load: 'qingstor/sdk'

      def needs_key?
        false
      end

      def check_auth
      end

      def check_app
      end

      def push_app
        glob_args = ['**/*']
        glob_args << File::FNM_DOTMATCH if options[:dot_match]
        Dir.chdir(options.fetch(:local_dir, Dir.pwd)) do
          Dir.glob(*glob_args) do |filename|
            file_path = [options[:local_dir], filename].compact.join('/')
            unless File.directory? file_path
              target_object_key = [options[:upload_dir], filename].compact.join('/')
              log "Uploading \"#{file_path}\" as \"#{target_object_key}\" in bucket \"#{bucket_name}\""

              md5_string = Digest::MD5.file(file_path).to_s
              result = bucket.put_object target_object_key, content_md5: md5_string, body: File.open(file_path)
              if result[:status_code] != 201
                warn "Error while uploading \"#{file_path}\""
              end
            end
          end
        end
      end

      private

      def bucket
        @bucket ||= service.bucket bucket_name, zone
      end

      def service
        @service ||= ::QingStor::SDK::Service.new config
      end

      def config
        @config ||= ::QingStor::SDK::Config.init access_key_id, secret_access_key
      end

      def access_key_id
        options[:access_key_id] || context.env['QINGSTOR_ACCESS_KEY_ID'] || raise(Error, 'missing access_key_id')
      end

      def secret_access_key
        options[:secret_access_key] || context.env['QINGSTOR_SECRET_ACCESS_KEY'] || raise(Error, 'missing secret_access_key')
      end

      def bucket_name
        options[:bucket_name] || context.env['QINGSTOR_BUCKET_NAME'] || raise(Error, 'missing bucket_name')
      end

      def zone
        result = service.list_buckets
        if result[:status_code] == 200
          zone = nil
          result[:buckets].each { |b| zone = b[:location] if b[:name] == bucket_name }
          return zone if zone
          raise Error, "The bucket \"#{bucket_name}\" you tried to write to is not found."
        end
        raise Error, 'Failed to list buckets.'
      end
    end
  end
end
