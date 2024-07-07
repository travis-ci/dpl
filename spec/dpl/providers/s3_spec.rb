# frozen_string_literal: true

describe Dpl::Providers::S3 do
  include Support::Matchers::Aws

  let(:args)   { |e| %w[--access_key_id access_key_id --secret_access_key secret_access_key --bucket bucket] + args_from_description(e) }
  let(:client) { Aws::S3::Client.new(stub_responses: {}) }

  file 'one.txt'
  file 'two/two.txt'
  file '.hidden.txt'

  before { allow(Aws::S3::Client).to receive(:new).and_return(client) }
  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    it { is_expected.to have_run '[info] Using Access Key: ac******************' }
    it { is_expected.to have_run '[info] Uploading 2 files with up to 5 threads ...' }
    it { is_expected.to have_run '[print] .' }
    it { is_expected.to have_run_in_order }
    # for whatever reason host would either include `us-stubbed-1` or not
    # depending if this spec is run as part of the full suite or alone.
    it { is_expected.to put_object 'one.txt', host: /bucket\.s3\.(us-stubbed-1\.)?amazonaws.com/, 'x-amz-acl': 'private', 'cache-control': 'no-cache', 'x-amz-storage-class': 'STANDARD' }
    it { is_expected.to put_object 'two/two.txt' }
  end

  describe 'given --endpoint https://host.com' do
    it { is_expected.to create_client endpoint: URI.parse('https://host.com') }
  end

  describe 'given --force_path_style' do
    it { is_expected.to create_client force_path_style: true }
  end

  describe 'given --region us-west-1' do
    it { is_expected.to create_client region: 'us-west-1' }
  end

  describe 'given --upload_dir dir' do
    it { is_expected.to put_object 'one.txt', path: '/dir/one.txt' }
  end

  describe 'given --local_dir two' do
    it { is_expected.to put_object 'two.txt', path: '/two.txt' }
  end

  describe 'given --glob two/*' do
    it { is_expected.to put_object 'two/two.txt', path: '/two/two.txt' }
  end

  describe 'given --dot_match' do
    it { is_expected.to have_run(/.hidden.txt/) }
    it { is_expected.to put_object '.hidden.txt' }
  end

  describe 'given --storage_class STANDARD_IA' do
    it { is_expected.to have_run(/one.txt.* storage_class=STANDARD_IA/) }
    it { is_expected.to put_object 'one.txt', 'x-amz-storage-class': 'STANDARD_IA' }
  end

  describe 'given --acl public_read' do
    it { is_expected.to have_run(/one.txt.* acl=public-read/) }
    it { is_expected.to put_object 'one.txt', 'x-amz-acl': 'public-read' }
  end

  describe 'given --cache_control public' do
    it { is_expected.to have_run(/one.txt.* cache_control=public/) }
    it { is_expected.to put_object 'one.txt', 'cache-control': 'public' }
  end

  describe 'given --cache_control max-age=60' do
    it { is_expected.to have_run(/one.txt.* cache_control=max-age=60/) }
    it { is_expected.to put_object 'one.txt', 'cache-control': 'max-age=60' }
  end

  describe 'given --cache_control "public, max-age=60: *.txt"' do
    it { is_expected.to have_run(/one.txt.* cache_control=public, max-age=60 /) }
    it { is_expected.to put_object 'one.txt', 'cache-control': 'public, max-age=60' }
  end

  describe 'given --expires "2020-01-01 00:00:00 UTC"' do
    it { is_expected.to have_run(/one.txt.* expires=2020-01-01 00:00:00 UTC/) }
    it { is_expected.to put_object 'one.txt', 'expires': 'Wed, 01 Jan 2020 00:00:00 GMT' }
  end

  describe 'given --default_text_charset utf-8' do
    it { is_expected.to have_run %r{one.txt.* content_type=text/plain; charset=utf-8} }
    it { is_expected.to put_object 'one.txt', 'content-type': 'text/plain; charset=utf-8' }
  end

  describe 'given --server_side_encryption' do
    it { is_expected.to have_run(/one.txt.* server_side_encryption=AES256/) }
    it { is_expected.to put_object 'one.txt', 'x-amz-server-side-encryption': 'AES256' }
  end

  describe 'given --detect_encoding' do
    it { is_expected.to have_run(/one.txt.* content_encoding=text/) }
    it { is_expected.to put_object 'one.txt', 'content-encoding': 'text' }
  end

  describe 'given --index_document_suffix suffix' do
    it { is_expected.to have_run '[info] Setting index document suffix to suffix' }
    it { is_expected.to put_bucket_website_suffix 'suffix' }
  end

  describe 'given --local_dir two', run: false do
    dir 'two'
    file 'two/two.txt'

    before { subject.run }

    it { is_expected.not_to put_object 'one.txt' }
    it { is_expected.to put_object 'two.txt' }
  end

  describe 'given --no-overwrite' do
    it { is_expected.to have_run '[warn] Skipping one.txt, already exists' }
  end

  describe 'with no mime-type being found', run: false do
    before do
      allow(MIME::Types).to receive(:type_for).and_return []
      subject.run
    end

    it { is_expected.not_to put_object 'one.txt', 'content-type': 'text/plain; charset=utf-8' }
  end

  describe 'with ~/.aws/credentials', run: false do
    let(:args) { |_e| %w[--bucket bucket] }

    file '~/.aws/credentials', <<-STR.sub(/^\s*/, '')
      [default]
      aws_access_key_id=access_key_id
      aws_secret_access_key=secret_access_key
    STR

    before { subject.run }

    it { is_expected.to have_run '[info] Using Access Key: ac******************' }
  end

  describe 'with ~/.aws/config', run: false do
    let(:args) { |_e| %w[--access_key_id id --secret_access_key key] }

    file '~/.aws/config', <<-STR.sub(/^\s*/, '')
      [default]
      region=us-other-1
      bucket=other
    STR

    before { subject.run }

    it { is_expected.to create_client region: 'us-other-1' }
    it { is_expected.to put_object 'one.txt', host: /other\.s3\.(us-stubbed-1\.)?amazonaws.com/ }
  end

  describe 'Mapping', run: false do
    subject(:s3) { Dpl::Providers::S3::Mapping.new(opt, path).value }

    let(:provider) { described_class.new(ctx, args) }
    let(:path) { 'one.css' }
    let(:opt) { |c| c.description.sub(/^given /, '') }

    it 'given no-cache' do
      expect(s3).to eq 'no-cache'
    end

    it 'given max-age=0' do
      expect(s3).to eq 'max-age=0'
    end

    it 'given max-age=0: one.css' do
      expect(s3).to eq 'max-age=0'
    end

    it 'given max-age=0: *.css' do
      expect(s3).to eq 'max-age=0'
    end

    it 'given max-age=0: *.css, *.js' do
      expect(s3).to eq 'max-age=0'
    end

    it 'given max-age=0: *.txt' do
      expect(s3).to be nil
    end

    it 'given 2020-01-01 00:00:00 UTC: *.css, *.js' do
      expect(s3).to eq '2020-01-01 00:00:00 UTC'
    end

    it 'given "2020-01-01 00:00:00 UTC": *.css, *.js' do
      expect(s3).to eq '2020-01-01 00:00:00 UTC'
    end
  end
end
