# frozen_string_literal: true

describe Dpl::Providers::Pypi do
  let(:args)   { |e| %w[--username user --password 1234] + args_from_description(e) }
  let(:server) { 'https://upload.pypi.org/legacy/' }

  # TODO: test env mappings

  let(:pypirc) do
    sq(<<-RC)
      [distutils]
      index-servers = pypi
          pypi
      [pypi]
      repository: #{server}
      username: user
      password: 1234
    RC
  end

  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    it { is_expected.to have_run %r{pip install .* setuptools twine wheel} }
    it { is_expected.to have_run '[info] Authenticated as user' }
    it { is_expected.to have_run 'python setup.py sdist' }
    it { is_expected.to have_run 'twine check dist/*' }
    it { is_expected.to have_run 'twine upload -r pypi dist/*' }
    it { is_expected.to have_run 'rm -rf dist/*' }
    it { is_expected.to have_written '~/.pypirc', pypirc }
    it { is_expected.to have_run_in_order }
    it { is_expected.not_to have_run(/upload_docs/) }
  end

  describe 'given --server other' do
    let(:server) { 'other' }

    it { is_expected.to have_written '~/.pypirc', pypirc }
  end

  describe 'given --distributions other' do
    it { is_expected.to have_run 'python setup.py other' }
  end

  describe 'given --upload_docs' do
    it { is_expected.to have_run 'python setup.py upload_docs --upload-dir build/docs -r https://upload.pypi.org/legacy/' }
  end

  describe 'given --upload_docs --docs_dir ./docs' do
    it { is_expected.to have_run 'python setup.py upload_docs --upload-dir ./docs -r https://upload.pypi.org/legacy/' }
  end

  describe 'given --no_twine_check' do
    it { is_expected.not_to have_run 'twine check dist/*' }
  end

  describe 'given --no_remove_build_dir' do
    it { is_expected.not_to have_run 'rm -rf dist/*' }
  end

  describe 'given --setuptools_version 1.0.0' do
    it { is_expected.to have_run %r{pip install .* setuptools==1.0.0} }
  end

  describe 'given --twine_version 1.0.0' do
    it { is_expected.to have_run %r{pip install .* twine==1.0.0} }
  end

  describe 'given --wheel_version 1.0.0' do
    it { is_expected.to have_run %r{pip install .* wheel==1.0.0} }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { [] }

    env PYPI_USERNAME: 'name',
        PYPI_PASSWORD: 'pass'
    it { expect { subject.run }.not_to raise_error }
  end
end
