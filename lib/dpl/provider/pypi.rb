module DPL
  class Provider
    class PyPI < Provider
      DEFAULT_SERVER = false
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

      def skip_upload_docs?
        ! options.has_key?(:skip_upload_docs) ||
          (options.has_key?(:skip_upload_docs) && options[:skip_upload_docs])
      end

      def pypi_skip_existing_option
          if options.fetch(:skip_existing, false)
            ' --skip-existing'
          end
      end

      def pypi_setuptools_arg
        setuptools_version = options[:setuptools_version] || context.env['SETUPTOOLS_VERSION'] || ''
        if setuptools_version[/\A\d+(?:\.\d+)*\z/]
          'setuptools==' + setuptools_version
        else
          'setuptools'
        end
      end

      def pypi_twine_arg
        twine_version = options[:twine_version] || context.env['TWINE_VERSION'] || ''
        if twine_version[/\A\d+(?:\.\d+)*\z/]
          'twine==' + twine_version
        else
          'twine'
        end
      end

      def pypi_wheel_arg
        wheel_version = options[:wheel_version] || context.env['WHEEL_VERSION'] || ''
        if wheel_version[/\A\d+(?:\.\d+)*\z/]
          'wheel==' + wheel_version
        else
          'wheel'
        end
      end

      def install_deploy_dependencies
        # --user likely fails inside virtualenvs but is needed outside to avoid needing sudo.
        unless context.shell "if [ -z ${VIRTUAL_ENV+x} ]; then export PIP_USER=yes; fi && " \
                             "wget -nv -O - https://bootstrap.pypa.io/get-pip.py | python - --no-setuptools --no-wheel && " \
                             "pip install --upgrade #{pypi_setuptools_arg} #{pypi_twine_arg} #{pypi_wheel_arg}"
          error "Couldn't install pip, setuptools, twine or wheel."
        end
      end

      def config
        servers = {
            'pypi' => [
                        "username: #{pypi_user}",
                        "password: #{pypi_password}",
                      ]
          }
        if pypi_server
          servers['pypi'].insert(0, "repository: #{pypi_server}")
        end
        {
          :header => '[distutils]',
          :servers_line => 'index-servers = pypi',
          :servers => servers
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
        unless context.shell "twine upload#{pypi_skip_existing_option} -r pypi dist/*"
          error 'PyPI upload failed.'
        end
        context.shell "rm -rf dist/*"
        unless skip_upload_docs?
          log "Uploading documentation (skip with \"skip_upload_docs: true\")"
          context.shell "python setup.py upload_docs #{pypi_docs_dir_option} -r #{pypi_server}"
        end
      end
    end
  end
end
