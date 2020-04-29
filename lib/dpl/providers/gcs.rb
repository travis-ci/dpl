require 'kconv'

module Dpl
  module Providers
    class Gcs < Provider
      register :gcs

      status :stable

      full_name 'Google Cloud Store'

      description sq(<<-str)
        tbd
      str

      gem 'mime-types', '~> 3.2.2'

      env :gcs

      required :key_file, [:access_key_id, :secret_access_key]

      opt '--key_file FILE', 'Path to a GCS service account key JSON file'
      opt '--access_key_id ID', 'GCS Interoperable Access Key ID', secret: true
      opt '--secret_access_key KEY', 'GCS Interoperable Access Secret', secret: true
      opt '--bucket BUCKET', 'GCS Bucket', required: true
      opt '--local_dir DIR', 'Local directory to upload from', default: '.'
      opt '--upload_dir DIR', 'GCS directory to upload to'
      opt '--dot_match', 'Upload hidden files starting with a dot'
      opt '--acl ACL', 'Access control to set for uploaded objects', default: 'private', enum: %w(private public-read public-read-write authenticated-read bucket-owner-read bucket-owner-full-control), see: 'https://cloud.google.com/storage/docs/reference-headers#xgoogacl'
      opt '--detect_encoding', 'HTTP header Content-Encoding to set for files compressed with gzip and compress utilities.'
      opt '--cache_control HEADER', 'HTTP header Cache-Control to suggest that the browser cache the file.', see: 'https://cloud.google.com/storage/docs/xml-api/reference-headers#cachecontrol'
      opt '--glob GLOB', default: '**/*'

      cmds install:   'curl -L %{URL} | tar xz -C ~ && ~/google-cloud-sdk/install.sh --path-update false --usage-reporting false --command-completion false',
           login_key: 'gcloud auth activate-service-account --key-file=%{key_file}',
           rsync:     'gsutil %{gs_opts} rsync %{rsync_opts} %{glob} %{target}',
           copy:      'gsutil %{gs_opts} cp %{copy_opts} -r %{source} %{target}'

      msgs login_key:   'Authenticating with service account key file %{key_file}',
           login_creds: 'Authenticating with access key: %{access_key_id}'

      errs copy:  'Failed uploading files.'

      URL = 'https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz'

      BOTO = sq(<<-str)
        [Credentials]
        gs_access_key_id = %{access_key_id}
        gs_secret_access_key = %{secret_access_key}
      str

      path '~/google-cloud-sdk'
      move '/etc/boto.cfg'

      def install
        shell :install
      end

      def login
        key_file? ? login_key : login_creds
      end

      def deploy
        Dir.chdir(local_dir) do
          files.each { |file| copy(file) }
        end
      end

      private

        def login_key
          shell :login_key
        end

        def login_creds
          info :login_creds
          write_boto
        end

        def write_boto
          write_file '~/.boto', interpolate(BOTO, opts, secure: true), 0600
        end

        def files
          Dir.glob(*glob_args).select { |path| File.file?(path) }
        end

        def copy(source)
          to = [target.sub(%r(/$), ''), source].join('/')
          shell :copy, gs_opts: gs_opts(source), source: source, target: to
        end

        def dirname(path)
          dir = File.dirname(path)
          dir unless dir.empty? || dir == '.'
        end

        def gs_opts(path)
          opts = []
          opts << %(-h "Cache-Control:#{cache_control}") if cache_control?
          opts << %(-h "Content-Encoding:#{encoding(path)}") if detect_encoding?
          opts << %(-h "Content-type:#{mime_type(path)}") if mime_type(path)
          opts.join(' ') + ' ' if opts.any?
        end

        def copy_opts
          opts = []
          opts << %(-a "#{acl}") if acl?
          opts.join(' ') + ' ' if opts.any?
        end

        def target
          "gs://#{bucket}/#{upload_dir}"
        end

        def mime_type(path)
          type = MIME::Types.type_for(path).first
          type.to_s if type
        end

        def glob_args
          args = [glob]
          args << File::FNM_DOTMATCH if dot_match?
          args
        end
    end
  end
end
