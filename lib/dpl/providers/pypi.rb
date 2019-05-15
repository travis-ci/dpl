module Dpl
  module Providers
    class Pypi < Provider
      full_name 'PyPI'

      description sq(<<-str)
        tbd
      str

      env :pypi

      opt '--username NAME', 'PyPI Username', required: true, alias: :user # support this in Cl and Env
      opt '--password PASS', 'PyPI Password', required: true
      opt '--server SERVER', 'Release to a different index', default: 'https://upload.pypi.org/legacy/'
      opt '--distributions DISTS', 'Space-separated list of distributions to be uploaded to PyPI', default: 'sdist'
      # this should have been --upload_docs or --[no-]skip_upload_docs ...
      opt '--skip_upload_docs BOOL', 'Skip uploading documentation. Note that upload.pypi.org does not support uploading documentation.', default: true, type: :boolean, see: 'https://github.com/travis-ci/dpl/issues/660'
      opt '--docs_dir DIR', 'Path to the directory to upload documentation from', default: 'build/docs'
      opt '--skip_existing', 'Do not overwrite an existing file with the same name on the server.'
      # not mentioned in the readme
      opt '--setuptools_version VER'
      opt '--twine_version VER'
      opt '--wheel_version VER'

      msgs login:        'Authenticated as %{username}',
           upload_docs:  'Uploading documentation (skip using "skip_upload_docs: true")'

      cmds setup_py:     'python setup.py %{distributions}',
           twine_upload: 'twine upload %{skip_existing_option} -r pypi dist/*',
           rm_dist:      'rm -rf dist/*',
           upload_docs:  'python setup.py upload_docs %{docs_dir_option} -r %{server}'

      errs install:      'Failed to install pip, setuptools, twine or wheel.',
           setup_py:     'setup.py failed',
           twine_upload: 'Twine upload failed.',
           upload_docs:  'Uploading docs failed.'

      VERSION = /\A\d+(?:\.\d+)*\z/ # add format to Cl

      def install
        script :install, assert: true
      end

      def login
        write_config
        info :login
      end

      def deploy
        shell :setup_py, assert: true
        shell :twine_upload, assert: true
        shell :rm_dist
        upload_docs unless skip_upload_docs?
      end

      private

        PYPIRC = sq(<<-rc)
          [distutils]
          index-servers = pypi
              pypi
          [pypi]
          repository: %{server}
          username: %{username}
          password: %{password}
        rc

        def write_config
          write_file('~/.pypirc', interpolate(PYPIRC))
        end

        def upload_docs
          info :upload_docs
          shell :upload_docs, assert: true
        end

        def skip_existing_option
          '--skip-existing' if skip_existing?
        end

        def docs_dir_option
          '--upload-dir ' + docs_dir if docs_dir
        end

        def setuptools_arg
          version_arg(:setuptools)
        end

        def twine_arg
          version_arg(:twine)
        end

        def wheel_arg
          version_arg(:wheel)
        end

        def version_arg(name)
          arg = name.to_s
          arg << "==#{send(:"#{name}_version")}" if send(:"#{name}_version") =~ VERSION
          arg
        end
    end
  end
end
