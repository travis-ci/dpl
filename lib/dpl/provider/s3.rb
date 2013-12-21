require 'json'

module DPL
  class Provider
    class S3 < Provider
      requires 'aws-sdk'

      def api
        @api ||= AWS::S3.new
      end

      def needs_key?
        false
      end

      def check_app

      end

      def setup_auth
        AWS.config(:access_key_id => option(:access_key_id), :secret_access_key => option(:secret_access_key))
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
            api.buckets[option(:bucket)].objects.create(upload_path(filename), File.read(filename)) unless File.directory?(filename)
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

    end
  end
end
