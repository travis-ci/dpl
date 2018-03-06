require 'chef'

module DPL
  class Provider
    class ChefSupermarket < Provider
      # Most of the code is inspired by:
      # https://github.com/opscode/chef/blob/11.16.4/lib/chef/knife/cookbook_site_share.rb

      attr_reader :cookbook_name, :cookbook_category
      attr_reader :cookbook

      def needs_key?
        false
      end

      def check_auth
        error "Missing user_id option" unless options[:user_id]
        error "Missing client_key option" unless options[:client_key]
        ::Chef::Config[:client_key] = options[:client_key]
        error "#{options[:client_key]} does not exist" unless ::File.exist?(options[:client_key])
      end

      def check_app
        @cookbook_name = options[:cookbook_name] || options[:app]
        @cookbook_category = options[:cookbook_category]
        unless cookbook_category
          error "Missing cookbook_category option\n" +
            "see https://docs.getchef.com/knife_cookbook_site.html#id12"
        end

        log "Validating cookbook #{cookbook_name}"
        # Check that cookbook exist and is valid
        # So we assume cookbook path is '..'
        cl = ::Chef::CookbookLoader.new '..'
        @cookbook = cl[cookbook_name]
        ::Chef::CookbookUploader.new(cookbook, '..').validate_cookbooks
      end

      def push_app
        log "Creating cookbook build directory"
        tmp_cookbook_dir = Chef::CookbookSiteStreamingUploader.create_build_dir(cookbook)
        log "Making tarball in #{tmp_cookbook_dir}"
        system("tar -czf #{cookbook_name}.tgz #{cookbook_name}", :chdir => tmp_cookbook_dir)

        uri = "https://supermarket.chef.io/api/v1/cookbooks"

        log "Uploading to #{uri}"
        category_string = { 'category'=>cookbook_category }.to_json
        http_resp = ::Chef::CookbookSiteStreamingUploader.post(
          uri,
          options[:user_id],
          options[:client_key],
          {
            :tarball => File.open("#{tmp_cookbook_dir}/#{cookbook_name}.tgz"),
            :cookbook => category_string
          }
        )
        res = ::Chef::JSONCompat.from_json(http_resp.body)
        if http_resp.code.to_i != 201
          if res['error_messages']
            if res['error_messages'][0] =~ /Version already exists/
              error "The same version of this cookbook already exists on the Opscode Cookbook Site."
            else
              error "#{res['error_messages'][0]}"
            end
          else
            error "Unknown error while sharing cookbook\n" +
              "Server response: #{http_resp.body}"
          end
        end

        log "Upload complete."
        ::FileUtils.rm_rf tmp_cookbook_dir
      end
    end
  end
end
