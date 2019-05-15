describe Dpl::Providers::CloudFiles do
  let(:storage) { Fog::Storage.new(provider: 'rackspace', rackspace_username: 'user', rackspace_api_key: 'key', rackspace_region: 'ord') }
  let(:args) { |e| %w(--username user --api_key key --region ord --container name) + args_from_description(e) }
  let(:dirs) { storage.directories }

  file :one
  file :two

  before do
    Fog.mock!
    dirs.create(key: 'name')
  end

  before { subject.run }

  describe 'by default' do
    it { expect(dirs.get('name').files.get('one').key).to eq 'one' }
    it { expect(dirs.get('name').files.get('two').key).to eq 'two' }
  end

  describe 'given --glob one' do
    it { expect(dirs.get('name').files.get('one').key).to eq 'one' }
    it { expect(dirs.get('name').files.get('two')).to be_nil }
  end
end
