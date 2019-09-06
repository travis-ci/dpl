describe Dpl::Providers::Bintray do
  let(:args) { |e| %w(--user user --key key --file descriptor.json) + args_from_description(e) }

  let(:paths) do
    {
      package:         %r(/packages/user/repo/name$),
      packages:        %r(/packages/user/repo$),
      package_attrs:   %r(/packages/user/repo/name/attributes$),
      version:         %r(/packages/user/repo/name/versions/0.5$),
      versions:        %r(/packages/user/repo/name/versions$),
      version_attrs:   %r(/packages/user/repo/name/versions/0.5/attributes$),
      version_file:    %r(/content/user/repo/name/0.5/gems/foo.gem$),
      version_sign:    %r(/gpg/user/repo/name/versions/0.5$),
      version_publish: %r(/content/user/repo/name/0.5/publish$),
      file_metadata:   %r(/file_metadata/user/repo/gems/foo.gem)
    }
  end

  let(:version_status) { 200 }
  let(:package_status) { 200 }

  file 'descriptor.json', fixture(:bintray, 'descriptor.json')
  file 'build/bin/foo.gem'

  before { stub_request(:head, paths[:package]).and_return status: package_status }
  before { stub_request(:head, paths[:version]).and_return status: version_status }
  before { stub_request(:post, paths[:packages]) }
  before { stub_request(:post, paths[:package_attrs]) }
  before { stub_request(:post, paths[:versions]) }
  before { stub_request(:post, paths[:version_attrs]) }
  before { stub_request(:put,  paths[:version_file]) }
  before { stub_request(:post, paths[:version_sign]) }
  before { stub_request(:post, paths[:version_publish]) }
  before { stub_request(:put,  paths[:file_metadata]) }

  before { |c| subject.run if run?(c) }

  describe 'creates a package if it does not exist, and updates package attributes' do
    let(:package) { { name: 'name', desc: 'desc', licenses: ['MIT'], labels: ['one', 'two', 'three'], vcs_url: 'vcs_url', website_url: 'website_url', issue_tracker_url: 'issue_tracker_url', public_download_numbers: false, public_stats: false } }
    let(:attrs)   { [{ name: 'foo', values: ['foo'], type: 'string' }, { name: 'bar', values: [1], type: 'number' }] }
    let(:package_status) { 404 }
    it { should have_requested(:post, paths[:packages]).with(body: package) }
    it { should have_requested(:post, paths[:package_attrs]).with(body: JSON.dump(attrs)) }
  end

  describe 'does not create a package or update package attributes if it exists' do
    it { should_not have_requested(:post, paths[:packages]) }
    it { should_not have_requested(:post, paths[:package_attrs]) }
  end

  describe 'creates a version if it does not exist, and updates version attributes' do
    let(:version) { { name: '0.5', desc: 'desc', released: '2015-01-01', vcs_tag: '0.5', attributes: [{ name: 'bar', values: ['bar'], type: 'string' }, { name: 'baz', values: [2], type: 'number' }] } }
    let(:attrs)   { [{ name: 'bar', values: ['bar'], type: 'string' }, { name: 'baz', values: [2], type: 'number' }] }
    let(:version_status) { 404 }
    it { should have_requested(:post, paths[:versions]).with(body: version) }
    it { should have_requested(:post, paths[:version_attrs]).with(body: JSON.dump(attrs)) }
  end

  describe 'does not create a version or update version attributes if it exists' do
    it { should_not have_requested(:post, paths[:versions]) }
    it { should_not have_requested(:post, paths[:version_attrs]) }
  end

  describe 'uploads a file matching the includePattern' do
    it { should have_requested(:put, paths[:version_file]) }
  end

  describe 'signs the version' do
    it { should have_requested(:post, paths[:version_sign]).with(body: {}) }

    describe 'given --passphrase phrase' do
      it { should have_requested(:post, paths[:version_sign]).with(body: { passphrase: 'phrase' }) }
    end
  end

  describe 'publishes the version' do
    it { should have_requested(:post, paths[:version_publish]) }
  end

  describe 'updates file metadata (list in downloads)' do
    it { should have_requested(:put, paths[:file_metadata]).with(body: '{"list_in_downloads":true}', headers: { 'Content-Type': 'application/json' }) }
  end

  describe 'missing descriptor file', run: false do
    before { rm 'descriptor.json' }
    it { expect { subject.run }.to raise_error 'Missing descriptor file: descriptor.json' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { %w(--file descriptor.json) }

    env BINTRAY_USER: 'user',
        BINTRAY_KEY: 'key'

    it { expect { subject.run }.to_not raise_error }
  end
end
