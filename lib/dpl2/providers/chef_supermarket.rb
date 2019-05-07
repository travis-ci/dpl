require 'chef'

module Dpl
  module Providers
    class ChefSupermarket < Provider
      summary 'Chef Supermarket deployment provider'

      description <<~str
        tbd
      str

      opt '--user_id ID',            'Chef Supermarket user name', required: true
      opt '--client_key KEY',        'Client API key file name', required: true
      opt '--cookbook_name NAME',    'Cookbook name. Defaults to the current working dir basename'
      opt '--cookbook_category CAT', 'Cookbook category in Supermarket. See: https://docs.getchef.com/knife_cookbook_site.html#id12', required: true

      URL = "https://supermarket.chef.io/api/v1/cookbooks"

      def setup
        Chef::Config[:client_key] = client_key
      end

      def check_auth
        error "#{client_key} does not exist" unless File.exist?(client_key)
      end

      def check_app
        info "Validating cookbook #{name}"
        uploader.validate_cookbooks
      end

      def deploy
        info "Uploading cookbook #{name} to #{URL}"
        upload
      end

      def finish
        FileUtils.rm_rf dir
      end

      private

        def upload
          res = upload
          handle_error(res.body) if res.code.to_i != 201
        end

        def post
          Chef::CookbookSiteStreamingUploader.post(URL, user_id, client_key,
            cookbook: json(category: cookbook_category),
            tarball:  tarball
          )
        end

        def tarball
          shell "tar -czf #{name}.tgz #{name}", chdir: dir
          File.open("#{dir}/#{name}.tgz")
        end

        def name
          cookbook_name || app
        end

        def cookbook
          @cookbook ||= loader[name]
        end

        def uploader
          Chef::CookbookUploader.new(cookbook, '..')
        end

        def loader
          Chef::CookbookLoader.new('..')
        end

        def dir
          @dir ||= Chef::CookbookSiteStreamingUploader.create_build_dir(cookbook)
        end

        def handle_error(res)
          res = JSON.parse(res)
          unknown_error(res) unless res['error_messages']
          version_exists if res['error_messages'][0].include?('Version already exists')
          error "#{res['error_messages'][0]}"
        end

        def unknown_error(msg)
          error "Unknown error while sharing cookbook\nServer response: #{msg}"
        end

        def version_exists
          error "The same version of this cookbook already exists on the Opscode Cookbook Site."
        end

        def json(obj)
          JSON.dump(obj)
        end
    end
  end
end
