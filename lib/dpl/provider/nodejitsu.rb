module DPL
  class Provider
    class Nodejitsu < Provider
      CONFIG_FILE = '.dpl/jitsu.json'
      requires 'json'
      npm_g 'jitsu'

      def config
        {
          "username"     => option(:username, :user_name, :user),
          "apiToken"     => option(:api_key),
          "apiTokenName" => "travis"
        }
      end

      def check_auth
        File.open(CONFIG_FILE, 'w') { |f| f << config.to_json }
      end

      def check_app
        error "missing package.json" unless File.exist? 'package.json'

        package = JSON.parse File.read('package.json')
        message = "missing %s in package.json, see https://www.nodejitsu.com/documentation/appendix/package-json/"
        error message % "subdomain"    unless package['subdomain']
        error message % "node version" unless package['engines'] and package['engines']['node']
        error message % "start script" unless package['scripts'] and package['scripts']['start']
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "jitsu deploy --jitsuconf #{File.expand_path(CONFIG_FILE)} --release=yes"
      end
    end
  end
end
