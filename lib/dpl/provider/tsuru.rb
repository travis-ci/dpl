module DPL
  class Provider
    class Tsuru < Provider
      require 'net/http'
      require "uri"
      require 'json'

      def initialize(context, options)
        super
        @deployment_branch = options[:deployment_branch]
	      uri = URI.parse(option(:server))
        @http = Net::HTTP.new(uri.host, uri.port)
      end

      def user
        @user ||= request_post('/auth/login', {:email => option(:email), :password => option(:password)})
      end

      def app
        @app ||= request_get("/apps/#{option(:app)}", get_header)
      end

      def check_auth
        log "authenticated as #{option(:email)}"
      end

      def check_app
        log "found app #{app['name']}"
      end

      def setup_key(file)
        request_post('/users/keys', {:name => option(:key_name), :key => File.read(file).chomp}, get_header)
      end

      def remove_key
        request_delete("/users/keys/#{option(:key_name)}", get_header)
      end

      def push_app
        if @deployment_branch
          log "deployment_branch detected: #{@deployment_branch}"
          app.deployment_branch = @deployment_branch
          context.shell "git push --force #{app['repository']} #{app.deployment_branch}"
        else
          context.shell "git push --force #{app['repository']} HEAD:master"
        end
      end


      private

      def get_header
        @get_header ||= {'Authorization' => "Bearer #{user['token']}", 'Content-Type' => 'application/x-www-form-urlencoded'}
      end

      def request_post(path, data, header = nil)
        req = Net::HTTP::Post.new(path, header)
        req.set_form_data(data)
        return request(req)
      end

      def request_get(path, header)
        req = Net::HTTP::Get.new(path, header)
        return request(req)
      end

      def request_delete(path, header)
        req = Net::HTTP::Delete.new(path, header)
        return request(req)
      end

      def request(req)
        res = @http.request(req)
        return JSON.parse(res.body) if res.body && res.body.length >= 2
      end
    end
  end
end
