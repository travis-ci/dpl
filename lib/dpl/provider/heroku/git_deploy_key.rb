module DPL
  class Provider
    module Heroku
      class GitDeployKey < Git
        def needs_key?
          false
        end

        def check_auth
          setup_git_ssh
        end

        def setup_git_ssh
          path = File.expand_path(".dpl/git-ssh")

          File.open(path, 'w') do |file|
            file.write "#!/bin/sh\n"
            file.write "exec ssh -o StrictHostKeychecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null -- \"$@\"\n"
          end

          chmod(0740, path)
          ENV['GIT_SSH'] = path
        end
      end
    end
  end
end
