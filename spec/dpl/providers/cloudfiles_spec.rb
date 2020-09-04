describe Dpl::Providers::Cloudfiles do
  let(:storage) { Fog::Storage.new(provider: 'rackspace', rackspace_username: 'user', rackspace_api_key: 'key', rackspace_region: 'ord') }
  let(:args) { |e| %w(--username user --api_key key --region ord --container name) + args_from_description(e) }
  let(:dirs) { storage.directories }

  file :one
  file :two

  before do
    Fog.mock!
    dirs.create(key: 'name')
  end

  before { |c| subject.run if run?(c) }

  describe 'by default' do
    it { expect(dirs.get('name').files.get('one').key).to eq 'one' }
    it { expect(dirs.get('name').files.get('two').key).to eq 'two' }
  end

  describe 'given --glob one' do
    it { expect(dirs.get('name').files.get('one').key).to eq 'one' }
    it { expect(dirs.get('name').files.get('two')).to be_nil }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { |e| %w(--region ord --container name) }

    env CLOUDFILES_USERNAME: 'user',
        CLOUDFILES_API_KEY: 'key'

    it { expect { subject.run }.to_not raise_error }
  end
end
