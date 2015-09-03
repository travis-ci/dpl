require 'json'

module DPL
  class Provider
    class S3 < Provider
      requires 'aws-sdk', version: '>= 2.0.22'
      requires 'mime-types'

      def api
        @api ||= ::Aws::S3::Resource.new(s3_options)
      end

      def needs_key?
        false
      end

      def check_app
        log 'Warning: The endpoint option is no longer used and can be removed.' if options[:endpoint]
      end

      def access_key_id
        options[:access_key_id] || context.env['AWS_ACCESS_KEY_ID'] || raise(Error, "missing access_key_id")
      end

      def secret_access_key
        options[:secret_access_key] || context.env['AWS_SECRET_ACCESS_KEY'] || raise(Error, "missing secret_access_key")
      end

      def s3_options
        {
          region:      options[:region] || 'us-east-1',
          credentials: ::Aws::Credentials.new(access_key_id, secret_access_key)
        }
      end

      def check_auth
        log "Logging in with Access Key: #{option(:access_key_id)[-4..-1].rjust(20, '*')}"
      end

      def upload_path(filename)
        [options[:upload_dir], filename].compact.join("/")
      end

      def push_app
        glob_args = ["**/*"]
        glob_args << File::FNM_DOTMATCH if options[:dot_match]
        Dir.chdir(options.fetch(:local_dir, Dir.pwd)) do
          Dir.glob(*glob_args) do |filename|
            content_type = MIME::Types.type_for(filename).first.to_s
            opts         = { :content_type => content_type }.merge(encoding_option_for(filename))
            opts[:cache_control] = get_option_value_by_filename(options[:cache_control], filename) if options[:cache_control]
            opts[:acl]           = options[:acl].gsub(/_/, '-') if options[:acl]
            opts[:expires]       = get_option_value_by_filename(options[:expires], filename) if options[:expires]
            unless File.directory?(filename)
              log "uploading %p" % filename
              api.bucket(option(:bucket)).object(upload_path(filename)).upload_file(filename, opts)
            end
          end
        end

        if suffix = options[:index_document_suffix]
          api.bucket(option(:bucket)).website.put(
            website_configuration: {
              index_document: {
                suffix: suffix
              }
            }
          )
        end
      end

      def deploy
        super
      rescue ::Aws::S3::Errors::InvalidAccessKeyId
        raise Error, "Invalid S3 Access Key Id, Stopping Deploy"
      rescue ::Aws::S3::Errors::ChecksumError
        raise Error, "Aws Secret Key does not match Access Key Id, Stopping Deploy"
      rescue ::Aws::S3::Errors::AccessDenied
        raise Error, "Oops, It looks like you tried to write to a bucket that isn't yours or doesn't exist yet. Please create the bucket before trying to write to it."
      end

      private
      def encoding_option_for(path)
        if detect_encoding? && encoding_for(path)
          {:content_encoding => encoding_for(path)}
        else
          {}
        end
      end

      def get_option_value_by_filename(option_values, filename)
        return option_values if !option_values.kind_of?(Array)
        preferred_value = nil
        hashes = option_values.select {|value| value.kind_of?(Hash) }
        hashes.each do |hash|
          hash.each do |value, patterns|
            unless patterns.kind_of?(Array)
              patterns = [patterns]
            end
            patterns.each do |pattern|
              if File.fnmatch?(pattern, filename)
                preferred_value = value
              end
            end
          end
        end
        preferred_value = option_values.select {|value| value.kind_of?(String) }.last if preferred_value.nil?
        return preferred_value
      end
    end
  end
end
