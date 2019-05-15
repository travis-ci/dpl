describe Dpl::Providers::Pypi do
  let(:args)   { |e| %w(--username user --password pass) + args_from_description(e) }
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
      password: pass
    rc
  end

  before { subject.run }

  describe 'by default', record: true do
    it { should have_run %r(pip install .* setuptools twine wheel) }
    it { should have_run '[info] Authenticated as user' }
    it { should have_run 'python setup.py sdist' }
    it { should have_run 'twine upload  -r pypi dist/*' }
    it { should have_run 'rm -rf dist/*' }
    it { should have_written '~/.pypirc', pypirc }
    it { should have_run_in_order }
  end

  describe 'given --server other' do
    let(:server) { 'other' }
    it { should have_written '~/.pypirc', pypirc }
  end

  describe 'given --distributions other' do
    it { should have_run 'python setup.py other' }
  end

  describe 'given --skip_upload_docs false' do
    it { should have_run 'python setup.py upload_docs --upload-dir build/docs -r https://upload.pypi.org/legacy/' }
  end

  describe 'given --skip_upload_docs false --docs_dir ./docs' do
    it { should have_run 'python setup.py upload_docs --upload-dir ./docs -r https://upload.pypi.org/legacy/' }
  end

  describe 'given --skip_existing' do
    it { should have_run 'twine upload --skip-existing -r pypi dist/*' }
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
end
