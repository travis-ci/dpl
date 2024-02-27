describe Dpl::Providers::Packagecloud do
  let(:args) { |e| %w(--username user --token token --repo repo) + args_from_description(e) }
  let(:url) { ['https', 'packagecloud.io', '443'] }
  let(:timeouts) { { connect_timeout: 60, read_timeout: 60, write_timeout: 180 } }
  let(:creds) { double }
  let(:conn) { double }

  let(:client) do
    double(
      find_distribution_id: 'id',
      delete_package: double(succeeded: true),
      put_package: double(succeeded: true),
      package_contents: double(succeeded: true, response: { 'files' => [] })
    )
  end

  before { allow(Packagecloud::Credentials).to receive(:new).with('user', 'token').and_return(creds) }
  before { allow(Packagecloud::Connection).to receive(:new).with(*url, timeouts).and_return(conn) }
  before { allow(Packagecloud::Client).to receive(:new).with(creds, anything, conn).and_return(client) }

  RSpec::Matchers.define :package do |path|
    match do |obj|
      obj.is_a?(Packagecloud::Package) &&
        obj.file.is_a?(File) &&
        obj.file.path == path &&
        obj.filename == path
    end
  end

  describe 'given --dist ubuntu/trusty', record: true do
    file 'one.tgz'
    before { subject.run }

    it { should have_run '[info] Logging in to https://packagecloud.io with user:t*******************' }
    it { should have_run '[info] Timeouts: connect_timeout=60 read_timeout=60 write_timeout=180' }
    it { should have_run '[info] Supported packages: one.tgz' }
    it { should have_run '[info] Pushing package: one.tgz to user/repo' }
    it { should have_run_in_order }
    it { should_not have_run '[info] Source packages: ' }

    it { expect(Packagecloud::Credentials).to have_received(:new).with('user', 'token') }
    it { expect(Packagecloud::Connection).to have_received(:new).with(*url, timeouts) }
    it { expect(client).to have_received(:put_package).with('repo', package('one.tgz'), 'id') }
  end

  # the whole source_files code path should be tested more, but it seems rather
  # unclear to me what this is actually supposed to do
  describe 'given --dist ubuntu/trusty', run: false do
    file 'one.dsc'
    before { subject.run }
    it { expect(client).to have_received(:put_package).with('repo', package('one.dsc'), 'id') }
  end

  describe 'given --dist ubuntu/trusty --force', run: false do
    file 'one.tgz'
    before { subject.run }
    it { expect(client).to have_received(:delete_package).with('repo', 'ubuntu', 'trusty', 'one.tgz') }
  end

  describe 'given --dist ubuntu/trusty --package_glob one* --package_glob two*', run: false do
    file 'one.tgz'
    file 'two.tgz'
    before { subject.run }
    it { expect(client).to have_received(:put_package).with('repo', package('one.tgz'), 'id') }
    it { expect(client).to have_received(:put_package).with('repo', package('two.tgz'), 'id') }
  end

  describe 'given --dist ubuntu/trusty --read_timeout 1 --write_timeout 1 --connect_timeout 1', run: false do
    let(:timeouts) { { connect_timeout: 1, read_timeout: 1, write_timeout: 1 } }
    file 'one.tgz'
    before { subject.run }
    it { expect(Packagecloud::Connection).to have_received(:new).with(*url, timeouts) }
  end

  describe 'missing dist', run: false do
    file 'one.tgz'
    it { expect { subject.run }.to raise_error 'Distribution needed for rpm, deb, python, and dsc packages (e.g. dist: ubuntu/breezy)' }
  end

  describe 'no packages', run: false do
    it { expect { subject.run }.to raise_error 'No supported packages found' }
  end

  # opt '--package_glob', type: :array, default: ['**/*']

  describe 'with credentials in env vars', run: false do
    let(:args) { %w(--dist ubuntu/trusty --repo repo) }
    env PACKAGECLOUD_USERNAME: 'user',
        PACKAGECLOUD_TOKEN: 'token'
    file 'one.tgz'
    it { expect { subject.run }.to_not raise_error }
  end
end
