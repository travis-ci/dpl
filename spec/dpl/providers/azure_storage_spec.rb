describe Dpl::Providers::AzureStorage do
  let(:args)   { |e| %w(--account name --access_key secret) + args_from_description(e) }
  let(:creds)  { { storage_account_name: 'name', storage_access_key: 'secret' } }
  let(:const)  { Azure::Storage::Blob::BlobService }
  let(:client) { double(create_block_blob: nil) }

  file 'dir/one.txt', 'one'
  file '.hidden.txt'

  before { allow(const).to receive(:create).and_return(client) }
  before { subject.run }

  describe 'by default' do
    it { should have_run '[info] Logging in to account name with access key s*******************' }
    it { should have_run '[info] Uploading dir/one.txt to $web' }
    it { expect(const).to have_received(:create).with(creds) }
    it { expect(client).to have_received(:create_block_blob).with('$web', 'dir/one.txt', 'one') }
    it { expect(client).to_not have_received(:create_block_blob).with('$web', '.hidden.txt', '') }
  end

  describe 'given --container other' do
    it { should have_run '[info] Uploading dir/one.txt to other' }
    it { expect(client).to have_received(:create_block_blob).with('other', 'dir/one.txt', 'one') }
  end

  describe 'given --local_dir dir' do
    it { should have_run '[info] Uploading one.txt to $web' }
    it { expect(client).to have_received(:create_block_blob).with('$web', 'one.txt', 'one') }
  end

  describe 'given --dot_match' do
    it { expect(client).to have_received(:create_block_blob).with('$web', '.hidden.txt', '') }
  end
end
