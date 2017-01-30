module DPL
  class Provider
    class Ansible < Provider
      pip 'ansible'

      def check_auth
      end

      def check_app
        playbook_file = playbook
        context.shell 'ansible-playbook --version'
        error "Application must have a playbook for unattended deployment. #{playbook_file} not found." unless File.exists? playbook_file
      end

      def needs_key?
        false
      end

      def push_app
        shell_cmd = assemble_cmd(options)
        if options[:debug]
          puts shell_cmd
        end
        context.shell shell_cmd
      end

      def cleanup
      end

      def uncleanup
      end

      def playbook
        return options[:playbook].nil? ? ".playbook.yml" : "#{options[:playbook]}"
      end

      def get_twodash_only_array
        result = ["become", "check", "diff", "flush-cache", "force-handlers",
          "syntax-check", "verbose", "version", "list-hosts", "list-tags",
          "list-tasks"]
        return result
      end

      def get_twodash_equal_array
        result = ["connection", "extra-vars", "forks", "inventory", "limit",
          "module-path", "private-key", "start-at-task", "ssh-common-args",
          "sftp-extra-args", "scp-extra-args", "ssh-extra-args", "skip-tags",
          "tags", "timeout", "user", "vault-password"]
        return result
      end

      def assemble_cmd(options)
        twodash_only_template = " --%{key}"
        twodash_equal_template = " --%{key}=%{value}"
        twodash_only = get_twodash_only_array
        twodash_equal = get_twodash_equal_array
        cmd = "ansible-playbook #{playbook}"

        options.each do |key, value|
          key = key.to_s
          key.tr!("_","-") if key.include?("_")
          next_arg=""
          option = {key: key, value: value}
          if twodash_only.include?(key) && value
            next_arg = twodash_only_template % option
          elsif twodash_equal.include?(key)
            next_arg = twodash_equal_template % option
          elsif key == "extra-args"
            next_arg = " " << value
          end
          cmd << next_arg
        end
        return cmd
      end

    end
  end
end
