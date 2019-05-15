describe Dpl::Providers::Gae do
  let(:args) { |e| %w(--project id) + args_from_description(e) }

  context do
    before { subject.run }

    describe 'by default', record: true do
      it { should have_run '[python:2.7] python -c "import sys; print(sys.version)"' }
      it { should have_run 'curl -L https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz | gzip -d | tar -x -C ~' }
      it { should have_run '[python:2.7] ~/google-cloud-sdk/bin/bootstrapping/install.py --usage-reporting=false --command-completion=false --path-update=false' }
      it { should have_run '[python:2.7] ~/google-cloud-sdk/bin/gcloud -q auth activate-service-account --key-file service-account.json' }
      it { should have_run '[python:2.7] ~/google-cloud-sdk/bin/gcloud --quiet --verbosity="warning" --project="id" --config="app.yaml" --promote' }
      it { should have_run_in_order }
    end

    describe 'given --keyfile ./keys' do
      it { should have_run '[python:2.7] ~/google-cloud-sdk/bin/gcloud -q auth activate-service-account --key-file ./keys' }
    end

    describe 'given --config ./config' do
      it { should have_run '[python:2.7] ~/google-cloud-sdk/bin/gcloud --quiet --verbosity="warning" --project="id" --config="./config" --promote' }
    end

    describe 'given --verbosity info' do
      it { should have_run '[python:2.7] ~/google-cloud-sdk/bin/gcloud --quiet --verbosity="info" --project="id" --config="app.yaml" --promote' }
    end

    describe 'given --no_promote' do
      it { should have_run '[python:2.7] ~/google-cloud-sdk/bin/gcloud --quiet --verbosity="warning" --project="id" --config="app.yaml" --no-promote' }
    end

    describe 'given --no_stop_previous_version' do
      it { should have_run '[python:2.7] ~/google-cloud-sdk/bin/gcloud --quiet --verbosity="warning" --project="id" --config="app.yaml" --promote --no-stop-previous-version' }
    end
  end

  context do
    env GOOGLECLOUDKEYFILE: './keys'
    before { subject.run }
    it { should have_run '[python:2.7] ~/google-cloud-sdk/bin/gcloud -q auth activate-service-account --key-file ./keys' }
  end

  context do
    let(:args) { [] }
    env GOOGLECLOUDPROJECT: 'id'
    before { subject.run }
    it { should have_run '[python:2.7] ~/google-cloud-sdk/bin/gcloud --quiet --verbosity="warning" --project="id" --config="app.yaml" --promote' }
  end

  context do
    let(:args) { [] }
    env CLOUDSDK_CORE_PROJECT: 'id'
    before { subject.run }
    it { should have_run '[python:2.7] ~/google-cloud-sdk/bin/gcloud --quiet --verbosity="warning" --project="id" --config="app.yaml" --promote' }
  end
end
