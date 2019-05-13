describe Dpl::Providers::Gcs do
  let(:args) { |e| %w(--access_key_id id --secret_access_key key --bucket bucket) + args_from_description(e) }

  chdir 'tmp'
  file 'one'
  file 'two/two'
  file '.hidden'

  before { stub_request(:put, /.*/) }
  before { subject.run }

  describe 'by default' do
    it { should have_run '[info] Logging in with Access Key: ********************' }
    it { expect(WebMock).to have_requested(:put, %r(bucket.*.com/one$)) }
    it { expect(WebMock).to_not have_requested(:put, %r(bucket.*.com/\.hidden$)) }
  end

  describe 'given --upload_dir ./dir' do
    it { expect(WebMock).to have_requested(:put, %r(bucket.*.com/dir/one$)) }
  end

  describe 'given --local_dir ./two' do
    it { expect(WebMock).to have_requested(:put, %r(bucket.*.com/two$)) }
  end

  describe 'given --dot_match' do
    it { expect(WebMock).to have_requested(:put, %r(bucket.*.com/\.hidden$)) }
  end

  describe 'given --acl public-read' do
    it { expect(WebMock).to have_requested(:put, %r(one)).with(headers: { 'X-Goog-Acl' => 'public-read' }) }
  end

  describe 'given --detect_encoding' do
    it { expect(WebMock).to have_requested(:put, %r(one)).with(headers: { 'Content-Encoding' => 'text' }) }
  end

  describe 'given --cache_control max-age=1' do
    it { expect(WebMock).to have_requested(:put, %r(one)).with(headers: { 'Cache-Control' => 'max-age=1' }) }
  end
end
