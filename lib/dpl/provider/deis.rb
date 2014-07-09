module DPL
  class Provider
    class Deis < Provider
      experimental 'Deis'
      pip 'deis', 'deis'

      def needs_key?
        true
      end

      def check_auth
        unless context.shell "deis login #{controller_url}" \
                      " --username=#{option(:username)}" \
                      " --password=#{option(:password)}"
          error 'Login failed.'
        end
      end

      def check_app
        unless context.shell "deis apps:info --app=#{option(:app)}"
          error 'Application could not be verified.'
        end
      end

      def setup_key(file)
        unless context.shell "deis keys:add #{file}"
          error 'Adding keys failed.'
        end
      end

      def setup_git_ssh(path, key_path)
        super(path, key_path)
        # Deis uses a non-standard port, so we need to create a
        # ssh config shortcut
        key_path = File.expand_path(key_path)
        add_ssh_config_entry(key_path)
        # A git remote is required for running commands
        # https://github.com/deis/deis/issues/1086
        add_git_remote
      end

      def remove_key
        unless context.shell "deis keys:remove #{option(:key_name)}"
          error 'Removing keys failed.'
        end
      end

      def push_app
        wait_until_key_is_set
        unless context.shell "git push #{git_push_url} HEAD:refs/heads/master -f"
          error 'Deploying application failed.'
        end
      end

      def run(command)
        unless context.shell "deis apps:run #{command}"
          error 'Running command failed.'
        end
      end

      private

      def wait_until_key_is_set
        sleep 5
      end

      def ssh_config_entry(key_file)
        "\nHost deis-repo\n" \
        "  Hostname #{option(:controller)}\n" \
        "  Port 2222\n" \
        "  User git\n" \
        "  IdentityFile #{key_file}\n"
      end

      def add_ssh_config_entry(key_file)
        FileUtils.mkdir_p(ssh_config_dir)
        File.open(ssh_config, 'a') { |f| f.write(ssh_config_entry(key_file)) }
      end

      def ssh_config
        File.join(ssh_config_dir, 'config')
      end

      def ssh_config_dir
        File.join(Dir.home, '.ssh')
      end

      def add_git_remote
        context.shell "git remote add deis #{git_remote_url}"
      end

      def git_push_url
        "deis-repo:#{option(:app)}.git"
      end

      def git_remote_url
        "ssh://git@#{option(:controller)}:2222/#{option(:app)}.git"
      end

      def controller_url
        "http://#{option(:controller)}"
      end
    end
  end
end
