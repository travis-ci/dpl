require 'uri'

# we want this, don't we?
Thread.abort_on_exception = true

module Dpl
  module Providers
    class Tam < Provider
      register :tam

      status :stable

      full_name 'Travis Artifacts Manager (TAM)'

      description sq(<<-str)
        tbd
      str

      gem 'aws-sdk-s3', '~> 1.0'

      env :AWS

      opt '--access_key_id ID', 'AWS access key id', required: true, secret: true
      opt '--secret_access_key KEY', 'AWS secret key', required: true, secret: true
      opt '--owner_name OWNERNAME', 'Repository owner name', required: true
      opt '--image_name NAME', 'Image name', required: true
      opt '--bucket BUCKET', 'S3 bucket', required: true
      opt '--upload_dir DIR', 'S3 directory to upload to'

      msgs checksum_error:        'AWS secret key does not match the access key id',
           invalid_access_key_id: 'Invalid S3 access key id',
           upload:                'Uploading %s files with up to %s threads ...',
           upload_file:           'Uploading %s to %s with %s',
           upload_failed:         'Failed to upload %s'

      def deploy
        upload
      rescue Aws::S3::Errors::ServiceError => e
        handle_error(e)
      end

      private

        def upload
          info :upload, files.length, 5
          threads = 5.times.map { |i| Thread.new(&method(:upload_files)) }
          threads.each(&:join)
        end

        def upload_files
          while file = files.pop
            upload_file(file, upload_opts(file))
          end
        end

        def upload_file(file, opts)
          object = bucket.object(upload_path(file))
          info :upload_file, file, upload_dir || '/', to_pairs(opts)
          object.upload_file(file, opts) || warn(:upload_failed, file)
        end

        def upload_path(file)
          [upload_dir, file].compact.join('/')
        end

        def upload_opts(file)
          {
            content_type: 'application/octet-stream',
          }
        end

        def files
          @files ||= Dir.glob("**/#{image_name}.tar.gz").reject { |path| File.directory?(path) }
        end

        def compact(hash)
          hash.reject { |_, value| value.nil? }.to_h
        end

        def handle_error(e)
          case e
          when Aws::S3::Errors::InvalidAccessKeyId
            error :invalid_access_key_id
          when Aws::S3::Errors::ChecksumError
            error :checksum_error
          when Aws::S3::Errors::AccessDenied
            error :access_denied
          else
            error e.message
          end
        end

        def bucket
          @bucket ||= Aws::S3::Resource.new(client: client).bucket(super)
        end

        def client
          Aws::S3::Client.new(credentials: credentials)
        end

        def credentials
          Aws::Credentials.new(access_key_id, secret_access_key)
        end

        def to_pairs(hash)
          hash.map { |pair| pair.join('=') }.join(' ')
        end
    end
  end
end
