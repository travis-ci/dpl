module DPL
  class Provider
    class Maven < Provider
      requires 'builder'

      SETTINGS_XML = './settings.xml'
      DEFAULT_ID = "nexus-releases"
      DEFAULT_URL = "https://oss.sonatype.org/service/local/staging/deploy/maven2/"

      def needs_key?
        false
      end

      def check_app
      end

      def setup_auth
      end

      def check_auth
      end

      def secret_key_file
        options[:secret_key_file]|| raise(Error, "missing secret_key_file")
      end

      def gpg_passphrase
        options[:gpg_passphrase]|| raise(Error, "missing gpg_passphrase")
      end

      def settings_xml
        xml = Builder::XmlMarkup.new( :indent => 2 )
        xml.instruct! :xml, :encoding => "UTF-8"
        xml.settings do |p|
          p.servers do |q|
            q.server do |server|
              server.id id
              server.username username
              server.password password 
            end
          end
        end
      end

      def username
        options[:username] || raise(Error, "missing username")
      end

      def password
        options[:password] || raise(Error, "missing password")
      end

      def retry_count
        options[:retry_count] || 1
      end

      def id
        options[:id]|| DEFAULT_ID
      end

      def url
        options[:url] || DEFAULT_URL
      end
      
      def push_app
        File.open(SETTINGS_XML, 'w') { |file| file.write(settings_xml) }
        context.shell "gpg --import #{secret_key_file()}"
        context.shell "mvn verify gpg:sign deploy:deploy --settings settings.xml -Dgpg.passphrase=#{gpg_passphrase()} -DaltDeploymentRepository=#{id()}::default::#{url()} -DretryFailedDeploymentCount=#{retry_count()}"
        File.delete(SETTINGS_XML)
      end
    end
  end
end
