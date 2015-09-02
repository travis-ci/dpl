module DPL
  class Provider
    class Deis < Provider
      def install_deploy_dependencies
        context.shell "curl -sSL http://deis.io/deis-cli/install.sh | sh -s #{option(:cli_version)}"
      end

      def needs_key?
        true
      end

      def check_auth
        unless context.shell "./deis login #{option(:controller)}" \
                      " --username=#{option(:username)}" \
                      " --password=#{option(:password)}"
          error 'Login failed.'
        end
      end

      def check_app
        unless context.shell "./deis apps:info --app=#{option(:app)}"
          error 'Application could not be verified.'
        end
      end

      def setup_key(file)
        unless context.shell "./deis keys:add #{file}"
          error 'Adding keys failed.'
        end
      end

      def setup_git_ssh(path, key_path)
        key_path = File.expand_path(key_path)
        path     = File.expand_path(path)

        File.open(path, 'w') do |file|
          file.write "#!/bin/sh\n"
          file.write "exec ssh -o StrictHostKeychecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null -i #{key_path} \"$@\"\n"
        end

        chmod(0740, path)
        context.env['GIT_SSH'] = path

        unless context.shell "./deis git:remote --app=#{option(:app)}"
          error 'Adding git remote failed.'
        end
      end

      def remove_key
        unless context.shell "./deis keys:remove #{option(:key_name)}"
          error 'Removing keys failed.'
        end
      end

      def push_app
        unless context.shell "git push deis HEAD:refs/heads/master -f"
          error 'Deploying application failed.'
        end
      end

      def run(command)
        unless context.shell "deis run -- #{command}"
          error 'Running command failed.'
        end
      end
    end
  end
end
