module DPL
  class Provider
    class Atlas < Provider
      GIMME_URL = 'https://raw.githubusercontent.com/meatballhat/gimme/master/gimme'
      ATLAS_UPLOAD_CLI_GO_REMOTE = 'github.com/hashicorp/atlas-upload-cli'
      ATLAS_UPLOAD_BOOL_ARGS = %w(vcs debug).map(&:to_sym).freeze
      ATLAS_UPLOAD_KV_ARGS = %w(address).map(&:to_sym).freeze
      ATLAS_UPLOAD_KV_MULTI_ARGS = %w(exclude include metadata).map(&:to_sym).freeze
      ATLAS_UPLOAD_INSTALL_SCRIPT = <<-EOF.gsub(/^ {8}/, '').strip
        if ! command -v atlas-upload &>/dev/null ; then
          mkdir -p $HOME/bin $HOME/gopath/src
          export PATH="$HOME/bin:$PATH"

          if ! command -v gimme &>/dev/null ; then
            curl -sL -o $HOME/bin/gimme #{GIMME_URL}
            chmod +x $HOME/bin/gimme
          fi

          if [ -z $GOPATH ]; then
            export GOPATH="$HOME/gopath"
          else
            export GOPATH="$HOME/gopath:$GOPATH"
          fi
          eval "$(gimme 1.6)" &> /dev/null

          go get #{ATLAS_UPLOAD_CLI_GO_REMOTE}
          cp $HOME/gopath/bin/atlas-upload-cli $HOME/bin/atlas-upload
        fi
      EOF

      experimental 'Atlas'

      def deploy
        assert_app_present!
        install_atlas_upload
        super
      end

      def check_auth
        ENV['ATLAS_TOKEN'] = options[:token] if options[:token]
        error 'Missing ATLAS_TOKEN' unless ENV['ATLAS_TOKEN']
      end

      def needs_key?
        false
      end

      def push_app
        unless options[:paths]
          here = Dir.pwd
          warn "No paths specified.  Using #{here.inspect}."
          options[:paths] = here
        end

        Array(options[:paths]).each do |path|
          context.shell "atlas-upload #{atlas_upload_args} #{atlas_app} #{path}"
        end
      end

      private

      def install_atlas_upload
        without_git_http_user_agent do
          context.shell ATLAS_UPLOAD_INSTALL_SCRIPT
        end
      end

      def assert_app_present!
        error 'Missing Atlas app name' unless options.key?(:app)
      end

      def atlas_upload_args
        return options[:args] if options.key?(:args)
        return @atlas_upload_args if @atlas_upload_args

        args = []

        ATLAS_UPLOAD_BOOL_ARGS.each do |arg|
          args << "-#{arg}" if options.key?(arg)
        end

        ATLAS_UPLOAD_KV_ARGS.each do |arg|
          args << ["-#{arg}", options[arg].inspect].join('=') if options.key?(arg)
        end

        ATLAS_UPLOAD_KV_MULTI_ARGS.each do |arg|
          next unless options.key?(arg)
          Array(options[arg]).each do |arg_entry|
            args << ["-#{arg}", arg_entry.inspect].join('=')
          end
        end

        @atlas_upload_args = args.join(' ')
      end

      def atlas_app
        @atlas_app ||= options.fetch(:app).to_s
      end

      def without_git_http_user_agent(&block)
        git_http_user_agent = ENV.delete("GIT_HTTP_USER_AGENT")
        yield
        ENV["GIT_HTTP_USER_AGENT"] = git_http_user_agent
      end

    end
  end
end
