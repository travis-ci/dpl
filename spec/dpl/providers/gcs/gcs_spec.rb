describe Dpl::Providers::Gcs::Gcs do
  let(:args) { |e| %w(--strategy gcs --bucket bucket --project_id foo-bar-12345 --credentials creds.json) + args_from_description(e) }
  
  before { stub_request(:put, /.*/) }
  before { subject.run }

  describe 'by default', record: true do
    it { should have_run 'mv /etc/boto.cfg /tmp/boto.cfg' }
    it { should have_run '[validate:runtime] python (>= 2.7.9)' }
    it { should have_run 'curl -L https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-252.0.0-linux-x86_64.tar.gz | tar xz -C ~ && ~/google-cloud-sdk/install.sh --path-update false --usage-reporting false --command-completion false' }
    it { should have_run '[info] Authenticating with access key: i*******************' }
    it { should have_run 'gsutil cp -r one gs://bucket/' }
    it { should have_run 'gsutil cp -r two/two gs://bucket/' }
    it { should have_run 'mv /tmp/boto.cfg /etc/boto.cfg' }
    it { should have_run_in_order }
    it { should_not have_run 'gsutil cp -r .hidden gs://bucket/' }
  end

end
