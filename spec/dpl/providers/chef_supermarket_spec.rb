describe Dpl::Providers::ChefSupermarket, memfs: true do
  let(:uploader) { Chef::CookbookUploader }
  let(:site)     { Chef::CookbookSiteStreamingUploader }

  let(:key)  { 'chef.validation.pem' }
  let(:url)  { 'https://supermarket.chef.io/api/v1/cookbooks' }
  let(:args) { |e| %W(--user_id id --client_key #{key} --cookbook_category cat) + args_from_description(e) }

  file 'validation.pem'
  dir  'build_dir'

  before do

    FileUtils.mkdir_p('tmp') # use memfs, add Support::File
    FileUtils.touch(key)

    # all this stubbing business makes the tests rather ineffective
    allow(File).to receive(:open).and_return 'tarball.tgz'
    allow(uploader).to receive(:new).and_return(double(validate_cookbooks: true))
    allow(site).to receive(:create_build_dir).and_return('build_dir')
    allow(site).to receive(:post).and_return(double(body: '{}', code: 201))
    subject.run
  end

  describe 'by default' do
    it { should have_run '[info] Validating cookbook dpl' }
    it { should have_run '[info] Uploading cookbook dpl to https://supermarket.chef.io/api/v1/cookbooks' }
    it { should have_run 'tar -czf dpl.tgz dpl' }
    it { should have_run_in_order }

    it do
      expect(site).to have_received(:post) do |*args|
        expect(args).to eq [url, 'id', key, cookbook: '{"category":"cat"}', tarball: 'tarball.tgz']
      end
    end
  end

  describe 'given --cookbook_name dpl.test' do
    before { FileUtils.mkdir_p('../dpl.test') } # use memfs
    after  { FileUtils.rm_rf('../dpl.test') }

    # it do
    #   expect(site).to have_received(:post) do |*args|
    #     expect(args).to eq [url, 'id', key, cookbook: '{"category":"cat"}', tarball: 'tarball.tgz']
    #   end
    # end
  end
end
