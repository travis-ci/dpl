# frozen_string_literal: true

require 'dpl/helper/cookbook_site_streaming_uploader'
describe Dpl::Providers::ChefSupermarket do
  let(:uploader) { Chef::CookbookUploader }
  let(:site)     { Chef::Knife::Core::CookbookSiteStreamingUploader }

  let(:args) { |e| %w[--user_id id --client_key chef.pem --cookbook_category cat] + args_from_description(e) }
  let(:url)  { 'https://supermarket.chef.io/api/v1/cookbooks' }

  file 'chef.pem'
  file 'metadata.json', '{"name":"dpl"}'
  file 'metadata.rb', 'name "dpl"'

  before do |c|
    # all this stubbing business makes the tests rather ineffective
    allow(File).to receive(:open).and_return 'tarball.tgz'
    allow(uploader).to receive(:new).and_return(double(validate_cookbooks: true))
    allow(site).to receive(:create_build_dir).and_return('build_dir')
    allow(site).to receive(:post).and_return(double(body: '{}', code: 201))
    subject.run if run?(c)
  end

  describe 'by default', record: true do
    let(:post) { [url, 'id', 'chef.pem', { cookbook: '{"category":"cat"}', tarball: 'tarball.tgz' }] }

    it { is_expected.to have_run '[info] Validating cookbook' }
    it { is_expected.to have_run '[info] Uploading cookbook dpl to https://supermarket.chef.io/api/v1/cookbooks' }
    it { is_expected.to have_run '[info] $ tar -czf /tmp/dpl.tgz -C build_dir .' }
    it { is_expected.to have_run 'tar -czf /tmp/dpl.tgz -C build_dir .' }
    it { is_expected.to have_run_in_order }

    it { expect(site).to have_received(:post) { |*args| expect(args).to eq post } }
  end

  describe 'missing client key', run: false do
    before { rm 'chef.pem' }

    it { expect { subject.run }.to raise_error 'Missing file: chef.pem' }
  end

  describe 'with a file metadata.rb', run: false do
    before do
      rm 'metadata.json'
      subject.run
    end

    it { is_expected.to have_run '[info] Uploading cookbook dpl to https://supermarket.chef.io/api/v1/cookbooks' }
  end

  describe 'missing both metadata.json and metadata.rb', run: false do
    before do
      rm 'metadata.json'
      rm 'metadata.rb'
    end

    it { expect { subject.run }.to raise_error 'Missing file: metadata.json or metadata.rb' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { %w[--client_key chef.pem --cookbook_category cat] }

    env CHEF_USER_ID: 'id'
    it { expect { subject.run }.not_to raise_error }
  end
end
