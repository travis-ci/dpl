# frozen_string_literal: true

module Dpl
  module Providers
    class ChefSupermarket < Provider
      register :'chef-supermarket'
      register :chef_supermarket

      status :alpha

      full_name 'Chef Supermarket'

      description sq(<<-STR)
        tbd
      STR

      gem 'date', '~> 3.3.4'
      gem 'time', '0.3.0'
      gem 'timeout', '0.4.1'
      gem 'chef', '~> 18', require: %w[
        chef/cookbook/cookbook_version_loader
        chef/cookbook_uploader
      ]

      gem 'json'
      gem 'mime-types', '~> 3.4.1'
      gem 'net-telnet', '~> 0.1.0' if ruby_pre?('2.3')
      gem 'rack'

      env :chef

      opt '--user_id ID',         'Chef Supermarket user name', required: true
      opt '--name NAME',          'Cookbook name', note: 'defaults to the name given in metadata.json or metadata.rb', alias: :cookbook_name, deprecated: :cookbook_name
      opt '--category CAT',       'Cookbook category in Supermarket', required: true, see: 'https://docs.getchef.com/knife_cookbook_site.html#id12', alias: :cookbook_category, deprecated: :cookbook_category
      opt '--client_key KEY',     'Client API key file name', default: 'client.pem'
      opt '--dir DIR',            'Directory containing the cookbook', default: '.'

      URL = 'https://supermarket.chef.io/api/v1/cookbooks'

      msgs validate: 'Validating cookbook',
           upload: 'Uploading cookbook %{name} to %{url}',
           missing_file: 'Missing file: %s',
           unknown_error: 'Unknown error while sharing cookbook: %s',
           version_exists: 'The same version of this cookbook already exists on the Opscode Cookbook Site.'

      def setup
        Chef::Config[:client_key] = client_key
        chdir dir
      end

      def validate
        info :validate
        validate_file client_key
        uploader.validate_cookbooks
      end

      def deploy
        info :upload
        upload
      end

      private

      def upload
        res = Chef::Knife::Core::CookbookSiteStreamingUploader.post(URL, user_id, client_key, params)
        handle_error(res.body) if res.code.to_i != 201
      end

      def params
        { cookbook: json(category:), tarball: }
      end

      def tarball
        shell "tar -czf /tmp/#{name}.tgz -C #{build_dir} ."
        shell "tar -tvf /tmp/#{name}.tgz"
        open "/tmp/#{name}.tgz"
      end

      def name
        @name ||= name_from_json || name_from_rb || error(:missing_file, 'metadata.json or metadata.rb')
      end

      def name_from_json
        JSON.parse(read('metadata.json'))['name'] if file?('metadata.json')
      end

      def name_from_rb
        Chef::Cookbook::Metadata.new.from_file('metadata.rb') if file?('metadata.rb')
      end

      def cookbook
        @cookbook ||= loader.cookbook_version
      end

      def loader
        Chef::Cookbook::CookbookVersionLoader.new('.').tap(&:load!)
      end

      def uploader
        Chef::CookbookUploader.new(cookbook)
      end

      def build_dir
        @build_dir ||= Chef::Knife::Core::CookbookSiteStreamingUploader.create_build_dir(cookbook)
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
        error (res['error_messages'][0]).to_s
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
