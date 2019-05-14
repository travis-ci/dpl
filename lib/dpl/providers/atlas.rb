module Dpl
  module Providers
    class Atlas < Provider
      description <<~str
        tbd
      str

      opt '--app APP',       'The Atlas application to upload to', required: true
      opt '--token TOKEN',   'The Atlas API token', required: true
      opt '--path PATH',     'Files or directories to upload', type: :array, default: ['.']
      opt '--address ADDR',  'The address of the Atlas server'
      opt '--include GLOB',  'Glob pattern of files or directories to include', type: :array
      opt '--exclude GLOB',  'Glob pattern of files or directories to exclude', type: :array
      opt '--metadata DATA', 'Arbitrary key=value (string) metadata to be sent with the upload', type: :array
      opt '--vcs',           'Get lists of files to exclude and include from a VCS (Git, Mercurial or SVN)'
      opt '--args ARGS',     'Args to pass to the atlas-upload CLI'
      opt '--debug',         'Turn on debug output'

      experimental 'Atlas'

      def setup
        ENV['ATLAS_TOKEN'] = token
      end

      def install
        script :install
      end

      def deploy
        path.each { |path| upload(path) }
      end

      private

        def upload(path)
          shell ['atlas-upload', args, app, path].compact.join(' ')
        end

        ARGS = %i(address exclude include metadata vcs debug)

        def args
          super || opts_for(ARGS, prefix: '-')
        end
    end
  end
end
