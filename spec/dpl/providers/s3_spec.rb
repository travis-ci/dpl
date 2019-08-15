describe Dpl::Providers::S3 do
  let(:args) { |e| %w(--access_key_id id --secret_access_key key --bucket bucket) + args_from_description(e) }
  let(:requests) { Hash.new { |hash, key| hash[key] = [] } }

  file 'one.txt'
  file '.hidden.txt'

  before do
    Aws.config[:s3] = {
      stub_responses: {
        put_object: ->(ctx) {
          requests[:put_object] << ctx.http_request
        },
        put_bucket_website: ->(ctx) {
          requests[:put_bucket_website] << ctx.http_request
        }
      }
    }
  end

  matcher :put_object do |file, opts = {}|
    match do |*|
      next false unless request = requests[:put_object].detect { |f| f.body.path == file }
      path = opts.delete(:path)
      return false if path && path != request.endpoint.path
      host = opts.delete(:host)
      return false if host && host != request.endpoint.host
      headers = symbolize(request.headers.to_h)
      expect(headers).to(include(opts)) if headers.any?
      true
    end
  end

  matcher :put_bucket_website_suffix do |suffix|
    match do |*|
      next false unless request = requests[:put_bucket_website][0]
      request.body.read.include?("<Suffix>#{suffix}</Suffix>")
    end
  end


  context do
    before { subject.run }

    describe 'by default', record: true do
      it { should have_run '[info] Using Access Key: i*******************' }
      it { should have_run '[info] Uploading 1 files with up to 5 threads.' }
      it { should have_run '[info] Uploading file one.txt to / with acl=private content_type=text/plain cache_control=no-cache storage_class=STANDARD' }
      it { should have_run_in_order }
      it { should put_object 'one.txt', host: 'bucket.s3.amazonaws.com', 'x-amz-acl': 'private', 'cache-control': 'no-cache', 'x-amz-storage-class': 'STANDARD' }
    end

    describe 'given --endpoint https://host.com' do
      it { should put_object 'one.txt', host: 'bucket.host.com' }
    end

    describe 'given --region us-west-1' do
      it { should put_object 'one.txt', host: 'bucket.s3.us-west-1.amazonaws.com' }
    end

    describe 'given --upload_dir dir' do
      it { should have_run %r(Uploading file one.txt to dir) }
      it { should put_object 'one.txt', path: '/dir/one.txt' }
    end

    describe 'given --dot_match' do
      it { should have_run %r(.hidden.txt) }
      it { should put_object '.hidden.txt' }
    end

    describe 'given --storage_class STANDARD_IA' do
      it { should have_run %r(one.txt.* storage_class=STANDARD_IA) }
      it { should put_object 'one.txt', 'x-amz-storage-class': 'STANDARD_IA' }
    end

    describe 'given --acl public_read' do
      it { should have_run %r(one.txt.* acl=public-read) }
      it { should put_object 'one.txt', 'x-amz-acl': 'public-read' }
    end

    describe 'given --cache_control public' do
      it { should have_run %r(one.txt.* cache_control=public) }
      it { should put_object 'one.txt', 'cache-control': 'public' }
    end

    describe 'given --cache_control max-age=60' do
      it { should have_run %r(one.txt.* cache_control=max-age=60) }
      it { should put_object 'one.txt', 'cache-control': 'max-age=60' }
    end

    describe 'given --expires "2020-01-01 00:00:00 UTC"' do
      it { should have_run %r(one.txt.* expires=2020-01-01 00:00:00 UTC) }
      it { should put_object 'one.txt', 'expires': 'Wed, 01 Jan 2020 00:00:00 GMT' }
    end

    describe 'given --default_text_charset utf-8' do
      it { should have_run %r(one.txt.* content_type=text/plain; charset=utf-8) }
      it { should put_object 'one.txt', 'content-type': 'text/plain; charset=utf-8' }
    end

    describe 'given --server_side_encryption' do
      it { should have_run %r(one.txt.* server_side_encryption=AES256) }
      it { should put_object 'one.txt', 'x-amz-server-side-encryption': 'AES256' }
    end

    describe 'given --detect_encoding' do
      it { should have_run %r(one.txt.* content_encoding=text) }
      it { should put_object 'one.txt', 'content-encoding': 'text' }
    end

    describe 'given --index_document_suffix suffix' do
      it { should have_run '[info] Setting index document suffix to suffix' }
      it { should put_bucket_website_suffix 'suffix' }
    end
  end

  describe 'given --local_dir two' do
    dir 'two'
    file 'two/two.txt'

    before { subject.run }
    it { should_not have_run %r(Uploading file one.txt) }
    it { should_not put_object 'one.txt' }
    it { should have_run %r(Uploading file two.txt) }
    it { should put_object 'two.txt' }
  end

  describe 'with ~/.aws/credentials' do
    let(:args) { |e| %w(--bucket bucket) }

    file '~/.aws/credentials', <<-str.sub(/^\s*/, '')
      [default]
      aws_access_key_id=access_key_id
      aws_secret_access_key=secret_access_key
    str

    before { subject.run }
    it { should have_run '[info] Using Access Key: ac******************' }
  end

  describe 'with ~/.aws/config' do
    let(:args) { |e| %w(--access_key_id id --secret_access_key key) }

    file '~/.aws/config', <<-str.sub(/^\s*/, '')
      [default]
      region=us-west-1
      bucket=other
    str

    before { subject.run }
    it { should put_object 'one.txt', host: 'other.s3.us-west-1.amazonaws.com' }
  end
end
