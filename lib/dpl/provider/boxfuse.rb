module DPL
  class Provider
    class Boxfuse < Provider

      def deploy
        @user = options[:user]
        @secret = options[:secret]
        @configfile = options[:configfile]
        @env = options[:env]

        @param_user = ''
        if @user.to_s != ''
          @param_user = " -user=" + @user
        end

        @param_secret = ''
        if @secret.to_s != ''
          @param_secret = " -secret=" + @secret
        end

        @param_configfile = ''
        if @configfile.to_s != ''
          @param_configfile = " -configfile=" + @configfile
        end

        @param_env = ' test'
        if @env.to_s != ''
          @param_env = " -env=" + @env
        end

        context.shell "curl -L https://files.boxfuse.com/com/boxfuse/client/boxfuse-commandline/latest/boxfuse-commandline-latest-linux-x64.tar.gz | tar xz"

        @command = "boxfuse/boxfuse run" + @param_user + @param_secret + @param_configfile + @param_env
        context.fold("Deploying application") { context.shell @command }
      end

    end
  end
end
