# frozen_string_literal: true

module Dpl
  module Providers
    class Pypi < Provider
      register :pypi

      status :stable

      full_name 'PyPI'

      description sq(<<-STR)
        tbd
      STR

      env :pypi

      VERSION = /\A\d+(?:\.\d+)*\z/

      env :pypi

      opt '--username NAME', 'PyPI Username', required: true, alias: :user
      opt '--password PASS', 'PyPI Password', required: true, secret: true
      opt '--server SERVER', 'Release to a different index', default: 'https://upload.pypi.org/legacy/'
      opt '--distributions DISTS', 'Space-separated list of distributions to be uploaded to PyPI', default: 'sdist'
      opt '--docs_dir DIR', 'Path to the directory to upload documentation from', default: 'build/docs'
      opt '--skip_existing', 'Do not overwrite an existing file with the same name on the server.'
      opt '--upload_docs', 'Upload documentation', default: false, type: :boolean, note: 'most PyPI servers, including upload.pypi.org, do not support uploading documentation'
      opt '--twine_check', 'Whether to run twine check', default: true
      opt '--remove_build_dir', 'Remove the build dir after the upload', default: true
      opt '--setuptools_version VER', format: VERSION
      opt '--twine_version VER', format: VERSION
      opt '--wheel_version VER', format: VERSION

      msgs login: 'Authenticated as %{username}',
           upload_docs: 'Uploading documentation (skip using "skip_upload_docs: true")'

      cmds setup_py: 'python setup.py %{distributions}',
           twine_check: 'twine check dist/*',
           twine_upload: 'twine upload %{skip_existing_option} -r pypi dist/*',
           rm_dist: 'rm -rf dist/*',
           upload_docs: 'python setup.py upload_docs %{docs_dir_option} -r %{server}'

      errs install: 'Failed to install pip, setuptools, twine or wheel.',
           setup_py: 'setup.py failed',
           twine_check: 'Twine check failed',
           twine_upload: 'Twine upload failed.',
           upload_docs: 'Uploading docs failed.'

      def install
        script :install
      end

      def login
        write_config
        info :login
      end

      def setup
        shell :setup_py
      end

      def validate
        shell :twine_check if twine_check?
      end

      def deploy
        shell :twine_upload
        upload_docs if upload_docs?
        shell :rm_dist if remove_build_dir?
      end

      private

      PYPIRC = sq(<<-RC)
          [distutils]
          index-servers = pypi
              pypi
          [pypi]
          repository: %{server}
          username: %{username}
          password: %{password}
      RC

      def write_config
        write_file('~/.pypirc', pypirc)
      end

      def pypirc
        interpolate(PYPIRC, opts, secure: true)
      end

      def upload_docs
        info :upload_docs
        shell :upload_docs
      end

      def skip_existing_option
        '--skip-existing' if skip_existing?
      end

      def docs_dir_option
        "--upload-dir #{docs_dir}" if docs_dir
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
