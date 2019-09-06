describe Dpl::Providers::Pypi do
  let(:args)   { |e| %w(--username user --password 1234) + args_from_description(e) }
  let(:server) { 'https://upload.pypi.org/legacy/' }

  # TODO test env mappings

  let(:pypirc) do
    sq(<<-rc)
      [distutils]
      index-servers = pypi
          pypi
      [pypi]
      repository: #{server}
      username: user
      password: 1234
    rc
  end

  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    it { should have_run %r(pip install .* setuptools twine wheel) }
    it { should have_run '[info] Authenticated as user' }
    it { should have_run 'python setup.py sdist' }
    it { should have_run 'twine check dist/*' }
    it { should have_run 'twine upload -r pypi dist/*' }
    it { should have_run 'rm -rf dist/*' }
    it { should have_written '~/.pypirc', pypirc }
    it { should have_run_in_order }
    it { should_not have_run /upload_docs/ }
  end

  describe 'given --server other' do
    let(:server) { 'other' }
    it { should have_written '~/.pypirc', pypirc }
  end

  describe 'given --distributions other' do
    it { should have_run 'python setup.py other' }
  end

  describe 'given --upload_docs' do
    it { should have_run 'python setup.py upload_docs --upload-dir build/docs -r https://upload.pypi.org/legacy/' }
  end

  describe 'given --upload_docs --docs_dir ./docs' do
    it { should have_run 'python setup.py upload_docs --upload-dir ./docs -r https://upload.pypi.org/legacy/' }
  end

  describe 'given --no_twine_check' do
    it { should_not have_run 'twine check dist/*' }
  end

  describe 'given --no_remove_build_dir' do
    it { should_not have_run 'rm -rf dist/*' }
  end

  describe 'given --setuptools_version 1.0.0' do
    it { should have_run %r(pip install .* setuptools==1.0.0) }
  end

  describe 'given --twine_version 1.0.0' do
    it { should have_run %r(pip install .* twine==1.0.0) }
  end

  describe 'given --wheel_version 1.0.0' do
    it { should have_run %r(pip install .* wheel==1.0.0) }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { [] }
    env PYPI_USERNAME: 'name',
        PYPI_PASSWORD: 'pass'
    it { expect { subject.run }.to_not raise_error }
  end
end
