describe Dpl::Providers::Tam do
  include Support::Matchers::Aws

  let(:args)   { |e| %w(--access_key_id access_key_id --secret_access_key secret_access_key --owner_name ownername --image_name imagename --bucket bucket --upload_dir somedir/somedir2)}
  let(:client) { Aws::S3::Client.new(stub_responses: {}) }

  file 'one.txt'
  file 'two/two.txt'
  file 'imagename.tar.gz'

  before { allow(Aws::S3::Client).to receive(:new).and_return(client) }

  describe 'by default', record: true do
    before { |c| subject.run if run?(c) }
    it { should have_run '[info] Uploading 1 files with up to 5 threads ...' }
    it { should have_run_in_order }
    it { should put_object 'imagename.tar.gz', host: /bucket\.s3/, path: '/somedir/somedir2/imagename.tar.gz' }
  end

  describe 'given ENV vars', record: true do
    let(:args)   { |e| %w(--owner-name ownername --image-name imagename --bucket bucket --upload-dir somedir/somedir2) }

    env AWS_ACCESS_KEY_ID: 'access_key_id',
        AWS_SECRET_ACCESS_KEY: 'secret_access_key'

    before { subject.run }

    it { should have_run '[info] Uploading 1 files with up to 5 threads ...' }
    it { should have_run_in_order }
    it { should put_object 'imagename.tar.gz', host: /bucket\.s3/, path: '/somedir/somedir2/imagename.tar.gz' }
  end
end
