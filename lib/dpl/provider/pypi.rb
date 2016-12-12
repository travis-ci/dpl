module DPL
  class Provider
    class PyPI < Provider
      DEFAULT_SERVER = 'https://pypi.python.org/pypi'
      PYPIRC_FILE = '~/.pypirc'

      def pypi_user
        option(:username, :user) || context.env['PYPI_USER'] || context.env['PYPI_USERNAME']
      end

      def pypi_password
        options[:password] || context.env['PYPI_PASSWORD']
      end

      def pypi_server
        options[:server] || context.env['PYPI_SERVER'] || DEFAULT_SERVER
      end

      def pypi_distributions
        options[:distributions] || context.env['PYPI_DISTRIBUTIONS'] || 'sdist'
      end

      def pypi_docs_dir_option
        docs_dir = options[:docs_dir] || context.env['PYPI_DOCS_DIR'] || ''
        if !docs_dir.empty?
          '--upload-dir ' + docs_dir
        end
      end

      def self.install_setuptools
        shell 'wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python'
        shell 'rm -f setuptools-*.zip'
      end

      def self.install_twine
        shell("pip install twine", retry: true) if `which twine`.chop.empty?
      end

      def initialize(*args)
        super(*args)
        self.class.pip 'wheel' if pypi_distributions.to_s.include? 'bdist_wheel'
      end

      install_setuptools
      install_twine

      def config
        {
          :header => '[distutils]',
          :servers_line => 'index-servers = pypi',
          :servers => {
            'pypi' => [
                         "repository: #{pypi_server}",
                         "username: #{pypi_user}",
                         "password: #{pypi_password}",
                      ]
          }
        }
      end

      def write_servers(f)
        config[:servers].each do |key, val|
          f.puts " " * 4 + key
        end

        config[:servers].each do |key, val|
          f.puts "[#{key}]"
          f.puts val
        end
      end

      def write_config
        File.open(File.expand_path(PYPIRC_FILE), 'w') do |f|
          config.each do |key, val|
            f.puts(val) if val.is_a? String or val.is_a? Array
          end
          write_servers(f)
        end
      end

      def check_auth
        error "missing PyPI username" unless pypi_user
        error "missing PyPI password" unless pypi_password
        write_config
        log "Authenticated as #{pypi_user}"
      end

      def check_app
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "python setup.py #{pypi_distributions}"
        context.shell "twine upload -r pypi dist/*"
        context.shell "rm -rf dist/*"
        unless options[:skip_upload_docs]
          log "Uploading documentation (skip with \"skip_upload_docs: true\")"
          context.shell "python setup.py upload_docs #{pypi_docs_dir_option} -r #{pypi_server}"
        end
      end
    end
  end
end
