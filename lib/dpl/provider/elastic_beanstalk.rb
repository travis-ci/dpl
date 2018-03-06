require 'time'
require 'aws-sdk'
require 'zip'

module DPL
  class Provider
    class ElasticBeanstalk < Provider
      experimental 'AWS Elastic Beanstalk'

      DEFAULT_REGION = 'us-east-1'

      def needs_key?
        false
      end

      def access_key_id
        options[:access_key_id] || context.env['AWS_ACCESS_KEY_ID'] || raise(Error, "missing access_key_id")
      end

      def secret_access_key
        options[:secret_access_key] || context.env['AWS_SECRET_ACCESS_KEY'] || raise(Error, "missing secret_access_key")
      end

      def check_auth
        options = {
          :region      => region,
          :credentials => Aws::Credentials.new(access_key_id, secret_access_key)
        }
        Aws.config.update(options)
      end

      def check_app
      end

      def only_create_app_version
        options[:only_create_app_version]
      end

      def push_app
        @start_time = Time.now
        create_bucket unless bucket_exists?

        if options[:zip_file]
          zip_file = File.expand_path(options[:zip_file])
        else
          zip_file = create_zip
        end

        s3_object = upload(archive_name, zip_file)
        sleep 5 #s3 eventual consistency
        version = create_app_version(s3_object)
        if !only_create_app_version
          update_app(version)
          wait_until_deployed if options[:wait_until_deployed]
        end
      end

      private

      def app_name
        option(:app)
      end

      def env_name
        options[:env] || context.env['ELASTIC_BEANSTALK_ENV'] || raise(Error, "missing env")
      end

      def version_label
        context.env['ELASTIC_BEANSTALK_LABEL'] || "travis-#{sha}-#{Time.now.to_i}"
      end

      def version_description
        context.env['ELASTIC_BEANSTALK_DESCRIPTION'] || commit_msg
      end

      def archive_name
        "#{version_label}.zip"
      end

      def region
        options[:region] || DEFAULT_REGION
      end

      def bucket_name
        option(:bucket_name)
      end

      def bucket_path
        @bucket_path ||= options[:bucket_path] ? option(:bucket_path).gsub(/\/*$/,'/') : nil
      end

      def s3
        @s3 ||= Aws::S3::Resource.new
      end

      def eb
        @eb ||= Aws::ElasticBeanstalk::Client.new
      end

      def bucket_exists?
        s3.bucket(bucket_name).exists?
      end

      def create_bucket
        s3.bucket(bucket_name).create
      end

      def files_to_pack
        `git ls-files -z`.split("\x0")
      end

      def create_zip
        directory = Dir.pwd
        zipfile_name = File.join(directory, archive_name)

        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          files_to_pack.each do |file|
            relative_archive_path = File.join(directory, '/')
            zipfile.add(file.sub(relative_archive_path, ''), file)
          end
        end
        zipfile_name
      end

      def upload(key, file)
        options = {
          :body => Pathname.new(file).open
        }
        bucket = s3.bucket(bucket_name)
        obj = bucket_path ? bucket.object("#{bucket_path}#{key}") : bucket.object(key)
        obj.put(options)
        obj
      end

      def create_app_version(s3_object)
        # Elastic Beanstalk doesn't support descriptions longer than 200 characters
        description = version_description[0, 200]
        options = {
          :application_name  => app_name,
          :version_label     => version_label,
          :description       => description,
          :source_bundle     => {
            :s3_bucket => bucket_name,
            :s3_key    => s3_object.key
          },
          :auto_create_application => false
        }
        eb.create_application_version(options)
      end

      # Wait until EB environment update finishes
      def wait_until_deployed
        errorEvents = 0 # errors counter, should remain 0 for successful deployment
        events = []

        loop do
          environment = eb.describe_environments({
            :application_name  => app_name,
            :environment_names => [env_name]
          })[:environments].first

          eb.describe_events({
            :environment_name  => env_name,
            :start_time        => @start_time.utc.iso8601,
          })[:events].reverse.each do |event|
            message = "#{event[:event_date]} [#{event[:severity]}] #{event[:message]}"
            unless events.include?(message)
              events.push(message)
              if event[:severity] == "ERROR"
                errorEvents += 1
                warn(message)
              else
                log(message)
              end
            end
          end

          break if environment[:status] == "Ready"
          sleep 5
        end

        if errorEvents > 0 then error("Deployment failed.") end
      end

      def update_app(version)
        options = {
          :environment_name  => env_name,
          :version_label     => version[:application_version][:version_label]
        }
        eb.update_environment(options)
      end
    end
  end
end
