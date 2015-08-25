module DPL
  class Provider
    class Boxfuse < Provider

      def deploy
        context.shell "curl -L https://files.boxfuse.com/com/boxfuse/client/boxfuse-commandline/latest/boxfuse-commandline-latest-linux-x64.tar.gz | tar xz"
        context.fold("Deploying application") { context.shell "boxfuse/boxfuse run" }
      end

    end
  end
end
