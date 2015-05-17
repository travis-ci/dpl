module DPL
  class Provider
    class Atlas < Provider
      GIMME_URL = 'https://raw.githubusercontent.com/meatballhat/gimme/master/gimme'
      ATLAS_UPLOAD_CLI_GO_REMOTE = 'github.com/hashicorp/atlas-upload-cli'
      ATLAS_UPLOAD_BOOL_OPTS = %w(vcs debug).map(&:to_sym).freeze
      ATLAS_UPLOAD_KV_OPTS = %w(address).map(&:to_sym).freeze
      ATLAS_UPLOAD_KV_MULTI_OPTS = %w(exclude include metadata).map(&:to_sym).freeze

      experimental 'Atlas'

      def self.install_atlas_upload
        shell <<-EOF.gsub(/^ {10}/, '')
          mkdir -p ~/bin ~/gopath/src
          if ! command -v gimme &>/dev/null ; then
            curl -sL -o ~/bin/gimme #{GIMME_URL}
            chmod +x ~/bin/gimme
          fi

          export GOPATH="$HOME/gopath:$GOPATH"
          eval "$(gimme 1.4.2)" &>/dev/null

          go get #{ATLAS_UPLOAD_CLI_GO_REMOTE}
          pushd ~/gopath/src/#{ATLAS_UPLOAD_CLI_GO_REMOTE} &>/dev/null
          make &>/dev/null
          cp bin/atlas-upload ~/bin/atlas-upload
          popd &>/dev/null
        EOF
      end

      install_atlas_upload

      def check_auth
        ENV['ATLAS_TOKEN'] = options[:token] if options[:token]
        error 'Missing ATLAS_TOKEN' unless ENV['ATLAS_TOKEN']
        assert_app_present!
      end

      def needs_key?
        false
      end

      def push_app
        assert_app_present!

        unless options[:paths]
          here = Dir.pwd
          warn "No paths specified.  Using #{here.inspect}."
          options[:paths] = here
        end

        Array(options[:paths]).each do |path|
          context.shell "~/bin/atlas-upload #{atlas_upload_options} #{atlas_app} #{path}"
        end
      end

      private

      def assert_app_present!
        error 'Missing Atlas app name' unless options.key?(:app)
      end

      def atlas_upload_options
        return @atlas_upload_options if @atlas_upload_options

        opts = []

        ATLAS_UPLOAD_BOOL_OPTS.each do |opt|
          opts << "-#{opt}" if options.key?(opt)
        end

        ATLAS_UPLOAD_KV_OPTS.each do |opt|
          opts << ["-#{opt}", options[opt].inspect].join('=') if options.key?(opt)
        end

        ATLAS_UPLOAD_KV_MULTI_OPTS.each do |opt|
          next unless options.key?(opt)
          Array(options[opt]).each do |opt_entry|
            opts << ["-#{opt}", opt_entry.inspect].join('=')
          end
        end

        @atlas_upload_options = opts.join(' ')
      end

      def atlas_app
        @atlas_app ||= options.fetch(:app).to_s
      end
    end
  end
end
