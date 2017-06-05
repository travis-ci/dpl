module DPL
  class Provider
    module Heroku
      class GitDeployKey < GitSSH
        deprecated(
          "git-deploy-key strategy is deprecated, and will be shut down on June 26, 2017.",
          "Please consider moving to the \`api\` or \`git\` strategy."
        )

        def needs_key?
          false
        end

        def check_auth
          super
          setup_git_ssh
        end

        def setup_git_ssh
          path = File.expand_path(".dpl/git-ssh")

          File.open(path, 'w') do |file|
            file.write "#!/bin/sh\n"
            file.write "exec ssh -o StrictHostKeychecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null -- \"$@\"\n"
          end

          chmod(0740, path)
          context.env['GIT_SSH'] = path
        end
      end
    end
  end
end
