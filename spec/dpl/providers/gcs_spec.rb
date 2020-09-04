describe Dpl::Providers::Gcs do
  file 'one'
  file 'two/two'
  file '.hidden'

  before { stub_request(:put, /.*/) }
  before { |c| subject.run if run?(c) }

  describe 'using --key_file' do
    let(:args) { |e| %w(--key_file key.json --bucket bucket) + args_from_description(e) }

    describe 'by default', record: true do
      it { should have_run 'mv /etc/boto.cfg /tmp/boto.cfg' }
      it { should have_run '[validate:runtime] python (>= 2.7.9)' }
      it { should have_run '[info] $ curl -L https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz | tar xz -C ~ && ~/google-cloud-sdk/install.sh --path-update false --usage-reporting false --command-completion false' }
      it { should have_run 'curl -L https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz | tar xz -C ~ && ~/google-cloud-sdk/install.sh --path-update false --usage-reporting false --command-completion false' }
      it { should have_run '[info] Authenticating with service account key file key.json' }
      it { should have_run '[info] $ gcloud auth activate-service-account --key-file=key.json' }
      it { should have_run 'gsutil cp -a "private" -r one gs://bucket/one' }
      it { should have_run 'gsutil cp -a "private" -r two/two gs://bucket/two/two' }
      it { should have_run 'mv /tmp/boto.cfg /etc/boto.cfg' }
      it { should have_run_in_order }
      it { should_not have_run 'gsutil cp -r .hidden gs://bucket/' }
    end

    describe 'given --upload_dir dir' do
      it { should have_run 'gsutil cp -a "private" -r one gs://bucket/dir/one' }
    end

    describe 'given --dot_match' do
      it { should have_run 'gsutil cp -a "private" -r .hidden gs://bucket/.hidden' }
    end

    describe 'given --acl public-read' do
      it { should have_run 'gsutil cp -a "public-read" -r one gs://bucket/one' }
    end

    describe 'given --detect_encoding' do
      it { should have_run 'gsutil -h "Content-Encoding:text" cp -a "private" -r one gs://bucket/one' }
    end

    describe 'given --cache_control max-age=1' do
      it { should have_run 'gsutil -h "Cache-Control:max-age=1" cp -a "private" -r one gs://bucket/one' }
    end

    describe 'with credentials in env vars', run: false do
      let(:args) { %w(--bucket bucket) }
      env GCS_ACCESS_KEY_ID: 'token',
          GCS_SECRET_ACCESS_KEY: '12345'
      it { expect { subject.run }.to_not raise_error }
    end
  end

  describe 'using --access_key_id and --secret_access_key' do
    let(:args) { |e| %w(--access_key_id id --secret_access_key 12345 --bucket bucket) + args_from_description(e) }

    describe 'by default', record: true do
      it { should have_run '[info] Authenticating with access key: i*******************' }
      it { should have_written '~/.boto', "[Credentials]\ngs_access_key_id = id\ngs_secret_access_key = 12345" }
    end
  end
end
