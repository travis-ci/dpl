module DPL
  class Provider
    class ElasticBeanstalk < Provider
      experimental 'AWS Elastic Beanstalk'

      requires 'aws-sdk-v1'
      requires 'rubyzip', :load => 'zip'

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
        AWS.config(access_key_id: access_key_id, secret_access_key: secret_access_key, region: region)
      end

      def check_app
      end

      def push_app
        create_bucket unless bucket_exists?

        if options[:zip_file]
          zip_file = File.join(Dir.pwd, options[:zip_file])
        else
          zip_file = create_zip
        end

        s3_object = upload(archive_name, zip_file)
        sleep 5 #s3 eventual consistency
        version = create_app_version(s3_object)
        update_app(version)
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
        @s3 ||= AWS::S3.new
      end

      def eb
        @eb ||= AWS::ElasticBeanstalk.new.client
      end

      def bucket_exists?
        s3.buckets.map(&:name).include? bucket_name
      end

      def create_bucket
        s3.buckets.create(bucket_name)
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
        obj = s3.buckets[bucket_name]
        obj = bucket_path ? obj.objects["#{bucket_path}#{key}"] : obj.objects[key]
        obj.write(Pathname.new(file))
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
