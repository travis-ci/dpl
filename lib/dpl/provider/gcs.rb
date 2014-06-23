require 'kconv'

module DPL
  class Provider
    class GCS < Provider
      requires 'gstore'
      requires 'mime-types'

      def needs_key?
        false
      end

      def client
        @client ||= GStore::Client.new(
          :access_key => option(:access_key_id),
          :secret_key => option(:secret_access_key)
        )
      end

      def check_auth
        log "Logging in with Access Key: #{option(:access_key_id)[-4..-1].rjust(20, '*')}"
      end

      def upload_path(filename)
        [options[:upload_dir], filename].compact.join("/")
      end

      def push_app
        Dir.chdir(options.fetch(:local_dir, Dir.pwd)) do
          Dir.glob("**/*") do |filename|
            next if File.directory?(filename)
            content_type = MIME::Types.type_for(filename).first.to_s
            opts                  = { :"Content-Type" => content_type }.merge(encoding_option_for(filename))
            opts["Cache-Control"] = options[:cache_control] if options[:cache_control]
            opts["x-goog-acl"]    = options[:acl] if options[:acl]

            client.put_object(
              option(:bucket),
              upload_path(filename),
              { :data => File.read(filename), :headers => opts }
            )
          end
        end
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
          {"Content-Encoding" => encoding_for(path)}
        else
          {}
        end
      end

    end
  end
end
