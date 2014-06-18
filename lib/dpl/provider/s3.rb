require 'json'

module DPL
  class Provider
    class S3 < Provider
      requires 'aws-sdk'
      requires 'mime-types'

      def api
        @api ||= AWS::S3.new(endpoint: options[:endpoint] || 's3.amazonaws.com')
      end

      def needs_key?
        false
      end

      def check_app

      end

      def setup_auth
        AWS.config(:access_key_id => option(:access_key_id), :secret_access_key => option(:secret_access_key), :region => options[:region]||'us-east-1')
      end

      def check_auth
        setup_auth
        log "Logging in with Access Key: #{option(:access_key_id)[-4..-1].rjust(20, '*')}"
      end

      def upload_path(filename)
        [options[:upload_dir], filename].compact.join("/")
      end

      def push_app
        Dir.chdir(options.fetch(:local_dir, Dir.pwd)) do
          Dir.glob("**/*") do |filename|
            content_type = MIME::Types.type_for(filename).first.to_s
            opts         = { :content_type => content_type }.merge(encoding_option_for(filename))
            opts[:cache_control] = options[:cache_control] if options[:cache_control]
            opts[:acl]           = options[:acl] if options[:acl] 
            opts[:expires]       = options[:expires] if options[:expires]
            unless File.directory?(filename)
              api.buckets[option(:bucket)].objects.create(upload_path(filename), File.read(filename), opts)
            end
          end
        end
      end

      def deploy
        super
      rescue AWS::S3::Errors::InvalidAccessKeyId
        raise Error, "Invalid S3 Access Key Id, Stopping Deploy"
      rescue AWS::S3::Errors::SignatureDoesNotMatch
        raise Error, "Aws Secret Key does not match Access Key Id, Stopping Deploy"
      rescue AWS::S3::Errors::AccessDenied
        raise Error, "Oops, It looks like you tried to write to a bucket that isn't yours or doesn't exist yet. Please create the bucket before trying to write to it."
      end

      private
      def detect_encoding?
        options[:detect_encoding]
      end

      def encoding_for(path)
        file_cmd_output = `file #{path}`
        case file_cmd_output
        when /gzip compressed/
          'gzip'
        when /compress'd/
          'compress'
        end
      end

      def encoding_option_for(path)
        if detect_encoding? && encoding_for(path)
          {:content_encoding => encoding_for(path)}
        else
          {}
        end
      end
    end
  end
end
