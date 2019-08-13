require 'google/cloud/storage'

module Dpl
  module Providers
    class Gcs
      class Gstore < Gcs
        status :alpha

        full_name 'Google Cloud Store'

        description sq(<<-str)
          tbd
        str
        
        gem 'google-cloud-storage'

        opt '--project_id ID', 'Project ID to which the bucket belongs', type: :string, required: true
        opt '--credentials CREDENTIALS_JSON_PATH', 'Path to the JSON file containing credentials', type: :string, required: true
        
        def push_app
          log "" # for accentuation
          glob_args = ["**/*"]
          glob_args << File::FNM_DOTMATCH if options[:dot_match]
          Dir.chdir(options.fetch(:local_dir, Dir.pwd)) do
            Dir.glob(*glob_args) do |filename|
              next if File.directory?(filename)
              opts = {}
              opts[:acl] = options[:acl] if options[:acl]
              opts[:cache_control] = options[:cache_control] if options[:cache_control]

              if remote_file = bucket.create_file(upload_path(filename), opts)
                log "Uploaded #{filename}"
              end
            end
          end
        end
                
        private
        def client
          @client ||= Google::Cloud::Storage.new(
            project_id: option(:project_id),
            credentials: option(:credentials)
          )
        rescue
          error "Unable to initialize GCS API client. Please check your project_id and credentials file"
        end

        def bucket
          @bucket ||= client.bucket(option(:bucket))
        rescue Google::Cloud::PermissionDeniedError
          error "Unable to access bucket #{option(:bucket)}. Ensure #{client.service_account_email} has 'Storage Admin' role assigned."
        end
        
        def validate
          !!(client && bucket)
        end
      end
    end
  end
end
