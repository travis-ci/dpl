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
        # upload zip
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

      def s3
        @s3 ||= AWS::S3.new
      end

      def bucket_exists?
        s3.buckets.map(&:name).include? S3_BUCKET
      end

      def create_bucket
        s3.buckets.create(S3_BUCKET)
      end

      def create_zip
        directory = Dir.pwd
        zipfile_name = "#{directory}/archive.zip"

        p directory

        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          Dir[File.join(directory, '**', '**')].each do |file|
            zipfile.add(file.sub(directory, ''), file)
          end
        end
        zipfile_name
      end

    end
  end
end
