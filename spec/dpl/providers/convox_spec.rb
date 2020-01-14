describe Dpl::Providers::Convox do
  let(:args)   { |e| %w(--app app --rack rack --password pass) + args_from_description(e) }
  let(:exists) { true }

  let(:desc) do
    Shellwords.escape JSON.dump(
      repo_slug: 'travis-ci/dpl',
      git_commit_sha: 'sha',
      git_commit_message: 'commit msg',
      git_commit_author: 'author name',
      git_tag: 'tag',
      branch: 'git branch',
      travis_build_id: '1',
      travis_build_number: '2',
      pull_request: '3'
    )
  end

  env TRAVIS_BUILD_ID: 1,
      TRAVIS_BUILD_NUMBER: 2,
      TRAVIS_PULL_REQUEST: 3,
      ONE: '$one',
      TWO: 'two',
      THREE: 'three'

  before { ctx.stdout[:validate] = exists }
  before { |c| subject.run unless c.metadata[:example_group][:run].is_a?(FalseClass) }

  describe 'by default', record: true do
    it { should have_env CONVOX_HOST: 'console.convox.com' }
    it { should have_env CONVOX_PASSWORD: 'pass' }
    it { should have_env CONVOX_APP: 'app' }
    it { should have_env CONVOX_RACK: 'rack' }
    it { should have_env CONVOX_CLI: 'convox' }

    it { should have_run %r(curl -sL -o \$HOME/bin/convox https://convox.com/cli/linux/convox) }
    it { should have_run '[info] $ convox version --rack rack' }
    it { should have_run 'convox version --rack rack' }
    it { should have_run '[info] Setting the build environment up for the deployment' }
    it { should have_run '[info] $ convox apps info --rack rack --app app' }
    it { should have_run 'convox apps info --rack rack --app app' }
    it { should have_run '[info] Building and promoting application ...' }
    it { should have_run "convox deploy --rack rack --app app --wait --id --description #{desc}" }
    it { should have_run_in_order }
  end

  describe 'app does not exist', run: false do
    let(:exists) { false }
    it { expect { subject.run }.to raise_error 'Application app does not exist on rack rack.' }
  end

  describe 'app does not exist, given --create' do
    let(:exists) { false }
    it { should have_run '[info] Application app does not exist on rack rack. Creating it ...' }
    it { should have_run '[info] $ convox apps create app --generation 2 --rack rack --wait' }
    it { should have_run 'convox apps create app --generation 2 --rack rack --wait' }
  end

  describe 'app does not exist, given --create --generation 1' do
    let(:exists) { false }
    it { should have_run 'convox apps create app --generation 1 --rack rack --wait' }
  end

  describe 'given --no-promote' do
    it { should have_run "convox build --rack rack --app app --id --description #{desc}" }
    it { should_not have_run /convox deploy/ }
  end

  describe 'given --host host' do
    it { should have_env CONVOX_HOST: 'host' }
  end

  describe 'given --install_url https://install.url' do
    it { should have_run %r(curl -sL -o \$HOME/bin/convox https://install.url) }
  end

  describe 'given --update_cli' do
    it { should have_run 'convox update' }
  end

  describe 'given --description other' do
    it { should have_run 'convox deploy --rack rack --app app --wait --id --description other' }
  end

  describe 'given --env ONE=$one --env TWO=two' do
    it { should have_run 'convox env set ONE\=\$one TWO\=two --rack rack --app app --replace' }
  end

  describe 'given --env ONE=$one --env TWO=two --env "THREE=three four five"' do
    it { should have_run 'convox env set ONE\=\$one TWO\=two THREE\=three\ four\ five --rack rack --app app --replace' }
  end

  describe 'given --env-names ONE --env-names TWO --env-names THREE' do
    it { should have_run 'convox env set ONE\=\$one TWO\=two THREE\=three --rack rack --app app --replace' }
  end

  describe 'given --env-names ONE,TWO,THREE' do
    it { should have_run 'convox env set ONE\=\$one TWO\=two THREE\=three --rack rack --app app --replace' }
  end

  describe 'given --env_file .env --env TWO=two', run: false do
    file '.env', 'ONE=$one'
    before { subject.run }
    it { should have_run 'convox env set ONE\=\$one TWO\=two --rack rack --app app --replace' }
  end

  describe 'missing env file, given --env_file .env', run: false do
    it { expect { subject.run }.to raise_error 'The given env_file does not exist.' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { |e| %w(--app app --rack rack) }

    env CONVOX_PASS: 'pass'

    it { expect { subject.run }.to_not raise_error }
  end
end
