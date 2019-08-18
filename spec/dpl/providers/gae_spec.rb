describe Dpl::Providers::Gae do
  let(:args) { |e| %w(--project id) + args_from_description(e) }

  before { |c| subject.run unless c.example_group.metadata[:run].is_a?(FalseClass) }

  describe 'by default', record: true do
    it { should have_run 'curl -L https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz | gzip -d | tar -x -C ~' }
    it { should have_run '~/google-cloud-sdk/bin/bootstrapping/install.py --usage-reporting=false --command-completion=false --path-update=false' }
    it { should have_run 'gcloud -q auth activate-service-account --key-file service-account.json' }
    it { should have_run 'gcloud -q app deploy app.yaml --project="id" --verbosity="warning"' }
    it { should have_run_in_order }
  end

  describe 'given --keyfile ./keys' do
    it { should have_run 'gcloud -q auth activate-service-account --key-file ./keys' }
  end

  describe 'given --config ./one --config ./two' do
    it { should have_run 'gcloud -q app deploy ./one ./two --project="id" --verbosity="warning"' }
  end

  describe 'given --verbosity info' do
    it { should have_run 'gcloud -q app deploy app.yaml --project="id" --verbosity="info"' }
  end

  describe 'given --no_promote' do
    it { should have_run 'gcloud -q app deploy app.yaml --project="id" --verbosity="warning" --no-promote' }
  end

  describe 'given --no_stop_previous_version' do
    it { should have_run 'gcloud -q app deploy app.yaml --project="id" --verbosity="warning" --no-stop-previous-version' }
  end

  describe 'given $GOOGLECLOUDKEYFILE', run: false do
    env GOOGLECLOUDKEYFILE: './keys'
    before { subject.run }
    it { should have_run 'gcloud -q auth activate-service-account --key-file ./keys' }
  end

  describe 'given $GOOGLECLOUDPROJECT', run: false do
    let(:args) { [] }
    env GOOGLECLOUDPROJECT: 'id'
    before { subject.run }
    it { should have_run 'gcloud -q app deploy app.yaml --project="id" --verbosity="warning"' }
  end

  describe 'given $CLOUDSDK_CORE_PROJECT', run: false do
    let(:args) { [] }
    env CLOUDSDK_CORE_PROJECT: 'id'
    before { subject.run }
    it { should have_run 'gcloud -q app deploy app.yaml --project="id" --verbosity="warning"' }
  end
end
