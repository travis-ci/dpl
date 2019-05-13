    # def create_key(file)
    #   context.shell "ssh-keygen -t rsa -N \"\" -C #{option(:key_name)} -f #{file}"
    # end
    #
    # def setup_git_credentials
    #   context.shell "git config user.email >/dev/null 2>/dev/null || git config user.email `whoami`@localhost"
    #   context.shell "git config user.name >/dev/null 2>/dev/null || git config user.name `whoami`@localhost"
    # end
    #
    # def setup_git_ssh(path, key_path)
    #   key_path = File.expand_path(key_path)
    #   path     = File.expand_path(path)
    #
    #   File.open(path, 'w') do |file|
    #     file.write "#!/bin/sh\n"
    #     file.write "exec ssh -o StrictHostKeychecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null -i #{key_path} -- \"$@\"\n"
    #   end
    #
    #   chmod(0740, path)
    #   context.env['GIT_SSH'] = path
    # end
    # def setup_dir
    #   # rm_rf '.dpl'
    #   # mkdir_p '.dpl'
    # end
    #
    #
    #   return unless needs_key?
    #   # extract this
    #   # create_key(".dpl/id_rsa")
    #   # setup_key(".dpl/id_rsa.pub")
    #   #
    #   # key_path = File.expand_path(".dpl/git-ssh")
    #   # path     = File.expand_path(".dpl/id_rsa")
    #   #
    #   # File.open(path, 'w') do |file|
    #   #   file.write "#!/bin/sh\n"
    #   #   file.write "exec ssh -o StrictHostKeychecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null -i #{key_path} -- \"$@\"\n"
    #   # end
    #   #
    #   # chmod(0740, path)
    #   # context.env['GIT_SSH'] = path
