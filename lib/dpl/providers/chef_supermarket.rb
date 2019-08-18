module Dpl
  module Providers
    class ChefSupermarket < Provider
      register :'chef-supermarket'
      register :chef_supermarket

      status :alpha

      full_name 'Chef Supermarket'

      description sq(<<-str)
        tbd
      str

      gem 'chef', '~> 12.0', require: %w(
        chef/cookbook/cookbook_version_loader
        chef/cookbook_site_streaming_uploader
        chef/cookbook_uploader
      )
      gem 'mime-types', '~> 3.2.2'
      gem 'net-telnet', '~> 0.1.0' if ruby_pre?('2.3')
      gem 'rack'

      opt '--user_id ID',         'Chef Supermarket user name', required: true
      opt '--client_key KEY',     'Client API key file name', required: true
      opt '--category CAT',       'Cookbook category in Supermarket', required: true, see: 'https://docs.getchef.com/knife_cookbook_site.html#id12', alias: :cookbook_category
      opt '--dir DIR',            'Directory containing the cookbook', default: '.'

      URL = "https://supermarket.chef.io/api/v1/cookbooks"

      msgs validate:       'Validating cookbook',
           upload:         'Uploading cookbook %{name} to %{url}',
           missing_file:   'Missing file: %s',
           unknown_error:  'Unknown error while sharing cookbook: %s',
           version_exists: 'The same version of this cookbook already exists on the Opscode Cookbook Site.'

      def setup
        Chef::Config[:client_key] = client_key
        Dir.chdir(dir)
      end

      def validate
        info :validate
        validate_file client_key
        validate_file 'metadata.rb'
        uploader.validate_cookbooks
      end

      def deploy
        info :upload
        upload
      end

      def finish
        FileUtils.rm_rf dir
      end

      private

        def upload
          res = Chef::CookbookSiteStreamingUploader.post(URL, user_id, client_key, params)
          handle_error(res.body) if res.code.to_i != 201
        end

        def params
          { cookbook: json(category: category), tarball: tarball }
        end

        def tarball
          shell "tar -czf #{name}.tgz #{build_dir}"
          File.open("#{build_dir}/#{name}.tgz")
        end

        def name
          @name ||= Chef::Cookbook::Metadata.new.from_file('metadata.rb')
        end

        def cookbook
          @cookbook ||= loader.cookbook_version
        end

        def loader
          Chef::Cookbook::CookbookVersionLoader.new('.')
        end

        def uploader
          Chef::CookbookUploader.new(cookbook)
        end

        def build_dir
          @build_dir ||= Chef::CookbookSiteStreamingUploader.create_build_dir(cookbook)
        end

        def validate_file(path)
          error :missing_file, path unless file?(path)
        end

        def url
          URL
        end

        def handle_error(res)
          res = JSON.parse(res)
          unknown_error(res) unless res['error_messages']
          version_exists if res['error_messages'][0].include?('Version already exists')
          error "#{res['error_messages'][0]}"
        end

        def unknown_error(msg)
          error :unknown_error, msg
        end

        def version_exists
          error :version_exists
        end

        def json(obj)
          JSON.dump(obj)
        end
    end
  end
end
