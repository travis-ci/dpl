require 'aws-sdk'
require 'zip'

module DPL
  class Provider
    class ElasticBeanstalk < Provider
      experimental 'AWS Elastic Beanstalk'

      S3_BUCKET = 'travis_elasticbeanstalk_builds'

      def needs_key?
        false
      end

      def check_auth
        AWS.config(access_key_id: option(:access_key_id), secret_access_key: option(:secret_access_key))
      end

      def check_app
      end

      def push_app
        create_bucket unless bucket_exists?
        zip_file = create_zip
        s3_object = upload(archive_name, zip_file)
        # add app version
        # update app with new version
      end

      private

      def app_name
        option(:app)
      end

      def env_name
        option(:env)
      end

      def archive_name
        "travis-#{sha}-#{Time.now.to_i}.zip"
      end

      def s3
        @s3 ||= AWS::S3.new
      end

      def eb
        @eb ||= AWS::ElasticBeanstalk.new.client
      end

      def bucket_exists?
        s3.buckets.map(&:name).include? S3_BUCKET
      end

      def create_bucket
        s3.buckets.create(S3_BUCKET)
      end

      def create_zip
        directory = Dir.pwd
        zipfile_name = File.join(directory, archive_name)

        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          Dir[File.join(directory, '**', '**')].each do |file|
            relative_archive_path = File.join(directory, '/')
            zipfile.add(file.sub(relative_archive_path, ''), file)
          end
        end
        zipfile_name
      end

      def upload(key, file)
        obj = s3.buckets[S3_BUCKET].objects[key]
        obj.write(Pathname.new(file))
        obj
      end

    end
  end
end
