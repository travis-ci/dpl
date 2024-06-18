# frozen_string_literal: true

require 'uri'

# we want this, don't we?
Thread.abort_on_exception = true

module Dpl
  module Providers
    class S3 < Provider
      register :s3

      status :stable

      full_name 'AWS S3'

      description sq(<<-STR)
        tbd
      STR

      gem 'nokogiri', '~> 1.15'
      gem 'aws-sdk-s3', '~> 1'
      gem 'mime-types', '~> 3.4.1'

      env :aws, :s3
      config '~/.aws/credentials', '~/.aws/config', prefix: 'aws'

      opt '--access_key_id ID', 'AWS access key id', required: true, secret: true
      opt '--secret_access_key KEY', 'AWS secret key', required: true, secret: true
      opt '--bucket BUCKET', 'S3 bucket', required: true
      opt '--region REGION', 'S3 region', default: 'us-east-1'
      opt '--endpoint URL', 'S3 endpoint'
      opt '--upload_dir DIR', 'S3 directory to upload to'
      opt '--local_dir DIR', 'Local directory to upload from', default: '.', example: '~/travis/build (absolute path) or ./build (relative path)'
      opt '--glob GLOB', 'Files to upload', default: '**/*'
      opt '--dot_match', 'Upload hidden files starting with a dot'
      opt '--acl ACL', 'Access control for the uploaded objects', default: 'private', enum: %w[private public_read public_read_write authenticated_read bucket_owner_read bucket_owner_full_control]
      opt '--detect_encoding', 'HTTP header Content-Encoding for files compressed with gzip and compress utilities'
      opt '--cache_control STR', 'HTTP header Cache-Control to suggest that the browser cache the file', type: :array, default: 'no-cache', enum: [/^no-cache.*/, /^no-store.*/, /^max-age=\d+.*/, /^s-maxage=\d+.*/, /^no-transform/, /^public/, /^private/], note: 'accepts mapping values to globs', eg: 'public: *.css,*.js'
      opt '--expires DATE', 'Date and time that the cached object expires', type: :array, format: /^"?\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} .+"?.*$/, note: 'accepts mapping values to globs', eg: '2020-01-01 00:00:00 UTC: *.css,*.js'
      opt '--default_text_charset CHARSET', 'Default character set to append to the content-type of text files'
      opt '--storage_class CLASS', 'S3 storage class to upload as', default: 'STANDARD', enum: %w[STANDARD STANDARD_IA REDUCED_REDUNDANCY]
      opt '--server_side_encryption', 'Use S3 Server Side Encryption (SSE-AES256)'
      opt '--index_document_suffix SUFFIX', 'Index document suffix of a S3 website'
      opt '--overwrite', 'Whether or not to overwrite existing files', default: true
      opt '--force_path_style', 'Whether to force keeping the bucket name on the path'
      opt '--max_threads NUM', 'The number of threads to use for S3 file uploads', default: 5, max: 15, type: :integer
      opt '--verbose', 'Be verbose about uploading files'

      msgs login: 'Using Access Key: %{access_key_id}',
           default_uri_schema: 'S3 endpoint does not specify a scheme; defaulting to https',
           access_denied: 'It looks like you tried to write to a bucket that is not yours or does not exist. Please create the bucket before trying to write to it.',
           checksum_error: 'AWS secret key does not match the access key id',
           invalid_access_key_id: 'Invalid S3 access key id',
           upload: 'Uploading %s files with up to %s threads ...',
           upload_file: 'Uploading %s to %s with %s',
           upload_skipped: 'Skipping %{file}, already exists',
           upload_failed: 'Failed to upload %s',
           index_document_suffix: 'Setting index document suffix to %s'

      DEFAULT_CONTENT_TYPE = 'application/octet-stream'

      def setup
        @cwd = Dir.pwd
        Dir.chdir(local_dir)
        # Aws.eager_autoload!(services: ['S3'])
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
        threads = max_threads.times.map { |_i| Thread.new(&method(:upload_files)) }
        threads.each(&:join)
        info "\n" unless verbose?
      end

      def upload_files
        while file = files.pop
          opts = upload_opts(file)
          progress(file, opts)
          upload_file(file, opts)
        end
      end

      def progress(file, data)
        if verbose?
          info :upload_file, file, upload_dir || '/', to_pairs(data)
        else
          print '.'
        end
      end

      def upload_file(file, opts)
        object = bucket.object(upload_path(file))
        return warn :upload_skipped, file: file if !overwrite && object.exists?

        info :upload_file, file, upload_dir || '/', to_pairs(opts)
        object.upload_file(file, opts) || warn(:upload_failed, file)
      end

      def index_document_suffix
        info :index_document_suffix, super
        body = { website_configuration: { index_document: { suffix: super } } }
        bucket.website.put(body)
      end

      def upload_path(file)
        [upload_dir, file].compact.join('/')
      end

      def upload_opts(file)
        compact(
          acl:,
          content_type: content_type(file),
          content_encoding: detect_encoding? ? encoding(file) : nil,
          cache_control: match_opt(cache_control, file),
          expires: match_opt(expires, file),
          storage_class:,
          server_side_encryption:
        )
      end

      def files
        @files ||= Dir.glob(*glob).reject { |path| File.directory?(path) }
      end

      def glob
        [super, dot_match? ? File::FNM_DOTMATCH : nil].compact
      end

      def acl
        super.gsub(/_/, '-') if acl?
      end

      def server_side_encryption
        'AES256' if server_side_encryption?
      end

      def content_type(file)
        return DEFAULT_CONTENT_TYPE unless type = MIME::Types.type_for(file).first

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

      def handle_error(err)
        case err
        when Aws::S3::Errors::InvalidAccessKeyId
          error :invalid_access_key_id
        when Aws::S3::Errors::ChecksumError
          error :checksum_error
        when Aws::S3::Errors::AccessDenied
          error :access_denied
        else
          error err.message
        end
      end

      def bucket
        @bucket ||= Aws::S3::Resource.new(client:).bucket(super)
      end

      def client
        Aws::S3::Client.new(s3_opts)
      end

      def s3_opts
        compact(
          region:,
          credentials:,
          endpoint:,
          force_path_style: force_path_style?
        )
      end

      def credentials
        Aws::Credentials.new(access_key_id, secret_access_key)
      end

      def to_pairs(hash)
        hash.map { |pair| pair.join('=') }.join(' ')
      end

      def match_opt(strs, file)
        maps = Array(strs).map { |str| Mapping.new(str, file) }
        maps.map(&:value).compact.first
      end

      class Mapping < Struct.new(:str, :file)
        MATCH = File::FNM_DOTMATCH | File::FNM_EXTGLOB

        def value
          str, glob = parse
          unquote(str) if match?(glob)
        end

        private

        def unquote(str)
          str =~ /^"(.*)"$/ && ::Regexp.last_match(1) || str
        end

        def match?(glob)
          glob.nil? || File.fnmatch?(normalize(glob), file, MATCH)
        end

        def normalize(glob)
          return glob if glob.include?('{')

          "{#{glob.split(',').map(&:strip).join(',')}}"
        end

        def parse
          parts = str.split(': ')
          parts.size > 1 ? [parts[0..-2].join(': '), parts.last] : parts
        end
      end
    end
  end
end
