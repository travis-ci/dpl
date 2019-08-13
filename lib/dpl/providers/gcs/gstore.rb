require 'kconv'

module Dpl
  module Providers
    class Gcs
      class Gstore < Gcs
        status :alpha

        full_name 'Google Cloud Store (with gstore)'

        description sq(<<-str)
          tbd
        str

        gem 'mime-types', '~> 3.2.2'

        python '>= 2.7.9'

        opt '--access_key_id ID', 'GCS Interoperable Access Key ID', required: true, secret: true
        opt '--secret_access_key KEY', 'GCS Interoperable Access Secret', required: true, secret: true
        opt '--bucket BUCKET', 'GCS Bucket', required: true
        opt '--local_dir DIR', 'Local directory to upload from', default: '.'
        opt '--upload_dir DIR', 'GCS directory to upload to'
        opt '--dot_match', 'Upload hidden files starting with a dot'
        opt '--acl ACL', 'Access control to set for uploaded objects'
        opt '--detect_encoding', 'HTTP header Content-Encoding to set for files compressed with gzip and compress utilities.'
        opt '--cache_control HEADER', 'HTTP header Cache-Control to suggest that the browser cache the file.'

        cmds install: 'curl -L %{URL} | tar xz -C ~ && ~/google-cloud-sdk/install.sh --path-update false --usage-reporting false --command-completion false',
             copy:    'gsutil %{gs_opts}cp %{copy_opts}-r %{source} %{target}'

        msgs login: 'Authenticating with access key: %{access_key_id}'

        errs copy:  'Failed uploading files.'

        URL = 'https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-252.0.0-linux-x86_64.tar.gz'

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
          info :login
          write_boto
        end

        def deploy
          Dir.chdir(local_dir) do
            source_files.each { |file| copy(file) }
          end
        end

        private

          def write_boto
            write_file '~/.boto', interpolate(BOTO, opts, secure: true), 0600
          end

          def source_files
            Dir.glob(*glob).select { |path| File.file?(path) }
          end

          def copy(source)
            shell :copy, gs_opts: gs_opts(source), source: source
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

          def glob
            glob = ['**/*']
            glob << File::FNM_DOTMATCH if dot_match?
            glob
          end
      end
    end
  end
end
