require 'kconv'

# gstore seems dead (it's archived on github)
#
# omg, and there's a PR to use https://github.com/googleapis/google-cloud-ruby
# https://github.com/travis-ci/dpl/pull/916/files
#
# well, i guess i'm done with the code now anyway :)

module Dpl
  module Providers
    class Gcs < Provider
      gem 'gstore', '~> 0.2.1', require: ['gstore', 'dpl/support/gstore_patch']
      gem 'mime-types', '~> 3.0'

      full_name 'Google Cloud Store'

      description sq(<<-str)
        tbd
      str

      opt '--access_key_id ID', 'GCS Interoperable Access Key ID', required: true
      opt '--secret_access_key KEY', 'GCS Interoperable Access Secret', required: true
      opt '--bucket BUCKET', 'GCS Bucket', required: true
      opt '--acl ACL', 'Access control to set for uploaded objects'
      opt '--upload_dir DIR', 'GCS directory to upload to', default: '.'
      opt '--local_dir DIR', 'Local directory to upload from. Can be an absolute (~/travis/build) or relative (build) path.', default: '.'
      opt '--dot_match', 'Upload hidden files starting with a dot'
      opt '--detect_encoding', 'HTTP header Content-Encoding to set for files compressed with gzip and compress utilities.'
      opt '--cache_control HEADER', 'HTTP header Cache-Control to suggest that the browser cache the file.'

      msgs login: 'Logging in with Access Key: %{obfuscated_access_key_id}'

      def login
        info :login
      end

      def deploy
        Dir.chdir(local_dir) do
          paths.each { |path| upload(path) }
        end
      end

      private

        def upload(path)
          params = { data: File.read(path), headers: headers(path) }
          gstore.put_object(bucket, upload_path(path), params)
        end

        def headers(path)
          compact(
            'Content-Type': mime_type(path),
            'Content-Encoding': encoding(path),
            'Cache-Control': cache_control,
            'x-goog-acl': acl
          )
        end

        def mime_type(path)
          MIME::Types.type_for(path).first.to_s
        end

        def paths
          Dir.glob(*glob).reject { |path| File.directory?(path) }
        end

        def glob
          glob = ["**/*"]
          glob << File::FNM_DOTMATCH if dot_match?
          glob
        end

        def upload_path(path)
          [upload_dir, path].compact.join('/')
        end

        def encoding(path)
          super if detect_encoding?
        end

        def gstore
          @gstore ||= GStore::Client.new(credentials)
        end

        def credentials
          { access_key: access_key_id, secret_key: secret_access_key }
        end
    end
  end
end
