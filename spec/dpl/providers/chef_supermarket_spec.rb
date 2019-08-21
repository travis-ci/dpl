describe Dpl::Providers::ChefSupermarket do
  let(:uploader) { Chef::CookbookUploader }
  let(:site)     { Chef::CookbookSiteStreamingUploader }

  let(:key)  { 'chef.validation.pem' }
  let(:url)  { 'https://supermarket.chef.io/api/v1/cookbooks' }
  let(:args) { |e| %W(--user_id id --client_key #{key} --cookbook_category cat) + args_from_description(e) }

  file 'chef.validation.pem'
  file 'metadata.rb', 'name "dpl"'

  before do
    # all this stubbing business makes the tests rather ineffective
    allow(File).to receive(:open).and_return 'tarball.tgz'
    allow(uploader).to receive(:new).and_return(double(validate_cookbooks: true))
    allow(site).to receive(:create_build_dir).and_return('build_dir')
    allow(site).to receive(:post).and_return(double(body: '{}', code: 201))
  end

  describe 'by default', record: true do
    before { subject.run }

    it { should have_run '[info] Validating cookbook' }
    it { should have_run '[info] Uploading cookbook dpl to https://supermarket.chef.io/api/v1/cookbooks' }
    it { should have_run 'tar -czf dpl.tgz build_dir' }
    it { should have_run_in_order }

    it do
      expect(site).to have_received(:post) do |*args|
        expect(args).to eq [url, 'id', key, cookbook: '{"category":"cat"}', tarball: 'tarball.tgz']
      end
    end
  end

  describe 'missing client key' do
    before { rm 'chef.validation.pem' }
    it { expect { subject.run }.to raise_error 'Missing file: chef.validation.pem' }
  end

  describe 'missing metadata.rb' do
    before { rm 'metadata.rb' }
    it { expect { subject.run }.to raise_error 'Missing file: metadata.rb' }
  end
end
