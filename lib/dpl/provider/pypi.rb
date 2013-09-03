module DPL
  class Provider
    class PyPI < Provider
      DEFAULT_SERVER = 'http://www.python.org/pypi'
      PYPIRC_FILE = '~/.pypirc'

      pip 'setuptools'

      def config
        {
          :header => '[distutils]',
          :servers_line => 'index-servers =',
          :servers => {
            'pypi' => [
                         "repository: #{options[:server] || DEFAULT_SERVER}",
                         "username: #{option(:user)}",
                         "password: #{option(:password)}",
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
        write_config
        log "Authenticated as #{option(:user)}"
      end

      def check_app
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "python setup.py register -r #{options[:server] || 'pypy'}"
        context.shell "python setup.py #{options[:distributions] || 'sdist'} upload -r #{options[:server] || 'pypi'}"
      end
    end
  end
end
