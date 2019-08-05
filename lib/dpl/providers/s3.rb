require 'uri'

# we want this, don't we?
Thread.abort_on_exception = true

module Dpl
  module Providers
    class S3 < Provider
      status :dev

      full_name 'AWS S3'

      description sq(<<-str)
        tbd
      str

      gem 'aws-sdk', '~> 2.0', require: ['aws-sdk', 'dpl/support/aws_sdk_patch']
      gem 'mime-types', '~> 3.2.2'

      env :aws

      # how come there is no glob or file option?
      opt '--access_key_id ID', 'AWS access key id', required: true, secret: true
      opt '--secret_access_key KEY', 'AWS secret key', required: true, secret: true
      opt '--bucket BUCKET', 'S3 bucket', required: true
      opt '--region REGION', 'S3 region', default: 'us-east-1'
      opt '--endpoint URL', 'S3 endpoint'
      opt '--upload_dir DIR', 'S3 directory to upload to'
      opt '--storage_class CLASS', 'S3 storage class to upload as', default: 'STANDARD', enum: %w(STANDARD STANDARD_IA REDUCED_REDUNDANCY)
      opt '--server_side_encryption', 'Use S3 Server Side Encryption (SSE-AES256)'
      opt '--local_dir DIR', 'Local directory to upload from', default: '.', example: '~/travis/build (absolute path) or ./build (relative path)'
      opt '--detect_encoding', 'HTTP header Content-Encoding for files compressed with gzip and compress utilities'
      opt '--cache_control STR', 'HTTP header Cache-Control to suggest that the browser cache the file', default: 'no-cache', enum: ['no-cache', 'no-store', /max-age=\d+/, /s-maxage=\d+/, 'no-transform', 'public', 'private']
      opt '--expires DATE', 'Date and time that the cached object expires', format: /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} .+$/
      opt '--acl ACL', 'Access control for the uploaded objects', default: 'private', enum: %w(private public_read public_read_write authenticated_read bucket_owner_read bucket_owner_full_control)
      opt '--dot_match', 'Upload hidden files starting with a dot'
      opt '--index_document_suffix SUFFIX', 'Index document suffix of a S3 website'
      opt '--default_text_charset CHARSET', 'Default character set to append to the content-type of text files'
      opt '--max_threads NUM', 'The number of threads to use for S3 file uploads', default: 5, max: 15, type: :integer

      msgs login:                 'Logging in with Access Key: %{access_key_id}',
           default_uri_schema:    'S3 endpoint does not specify a scheme; defaulting to https',
           access_denied:         'It looks like you tried to write to a bucket that is not yours or does not exist. Please create the bucket before trying to write to it.',
           checksum_error:        'AWS secret key does not match the access key id',
           invalid_access_key_id: 'Invalid S3 access key id',
           upload:                'Uploading %s files with up to %s threads.',
           upload_file:           'Uploading file %s to %s with %s',
           upload_failed:         'Failed to upload %s',
           index_document_suffix: 'Setting index document suffix to %s'

      def setup
        @cwd = Dir.pwd
        Dir.chdir(local_dir)
        Aws.eager_autoload!(services: ['S3'])
      end

      def login
        info :login
      end

      def deploy
        upload
        index_document_suffix if index_document_suffix?
      rescue Aws::S3::Errors::ServiceError => e
        handle_error(e)
      end

      def finish
        Dir.chdir(@cwd) if @cwd
      end

      private

        def upload
          info :upload, files.length, max_threads
          threads = max_threads.times.map { |i| Thread.new(&method(:upload_files)) }
          threads.each(&:join)
        end

        def upload_files
          while file = files.pop
            data = content_data(file)
            info :upload_file, file, upload_dir || '/', to_pairs(data)
            object = s3.bucket(bucket).object(upload_path(file))
            object.upload_file(file, data) || warn(:upload_failed, file)
          end
        end

        def index_document_suffix
          info :index_document_suffix, super
          body = { website_configuration: { index_document: { suffix: super } } }
          s3.bucket(bucket).website.put(body)
        end

        def upload_path(file)
          [upload_dir, file].compact.join('/')
        end

        def content_data(file)
          compact(
            acl: acl,
            content_type: content_type(file),
            content_encoding: detect_encoding? ? encoding(file) : nil,
            cache_control: cache_control,
            expires: expires,
            storage_class: storage_class,
            server_side_encryption: server_side_encryption
          )
        end

        def files
          @files ||= Dir.glob(*glob).reject { |path| File.directory?(path) }
        end

        def glob
          ['**/*', dot_match? ? File::FNM_DOTMATCH : nil].compact
        end

        def acl
          super.gsub(/_/, '-') if acl?
        end

        def cache_control
          # get_option_value_by_filename(super, file) if cache_control?
          super
        end

        def expires
          # get_option_value_by_filename(super, file) if expires?
          super
        end

        def server_side_encryption
          'AES256' if server_side_encryption?
        end

        def content_type(file)
          return unless type = MIME::Types.type_for(file).first
          type = "#{type}; charset=#{default_text_charset}" if encoding(file) == 'text' && default_text_charset?
          type.to_s
        end

        def compact(hash)
          hash.reject { |_, value| value.nil? }.to_h
        end

        def endpoint
          @endpoint ||= normalize_endpoint(super) if endpoint?
        end

        def normalize_endpoint(url)
          uri = URI.parse(url)
          return uri if uri.scheme
          info :default_uri_scheme
          URI.parse("https://#{url}")
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

        def s3
          @s3 ||= Aws::S3::Resource.new(compact(region: region, credentials: credentials, endpoint: endpoint))
        end

        def credentials
          Aws::Credentials.new(access_key_id, secret_access_key)
        end

        def to_pairs(hash)
          hash.map { |pair| pair.join('=') }.join(' ')
        end

        # i don't think this has ever worked. travis-build does not seem to turn
        # the given hashes into anything useful here https://github.com/travis-ci/travis-build/blob/master/lib/travis/build/addons/deploy/script.rb#L187
        #
        # more importantly, the tests test against Ruby hashes, but the logic here
        # never parses a given string into a hash.
        #
        # (also, why does travis-build use data.branch there?)

        # def get_option_value_by_filename(opts, filename)
        #   return opts if !opts.kind_of?(Array)
        #   preferred_value = nil
        #   hashes = opts.select { |value| value.kind_of?(Hash) }
        #   hashes.each do |hash|
        #     hash.each do |value, patterns|
        #       unless patterns.kind_of?(Array)
        #         patterns = [patterns]
        #       end
        #       patterns.each do |pattern|
        #         if File.fnmatch?(pattern, filename)
        #           preferred_value = value
        #         end
        #       end
        #     end
        #   end
        #   preferred_value = opts.select {|value| value.kind_of?(String) }.last if preferred_value.nil?
        #   return preferred_value
        # end
    end
  end
end
