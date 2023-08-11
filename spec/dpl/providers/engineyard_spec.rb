# frozen_string_literal: true

describe Dpl::Providers::Engineyard do
  let(:args)    { |e| %w[--api_key key] + args_from_description(e) }
  let(:headers) { { content_type: 'application/json' } }

  let(:envs) do
    <<-STR.gsub(/^\s+/, '')
      ID | Name | Account
      ---|------|-----------
      1  | env  | account
    STR
  end

  let(:whoami) do
    <<-STR.gsub(/^\s+/, '')
      User:f7ecb9e2-946c-47ae-8ae1-2ef44aab3486 {
        email : "dpl-test@travis-ci.org"
      }
    STR
  end

  before do
    ctx.stdout.update(
      envs:,
      whoami:
    )
  end

  before { |c| subject.run if run?(c) }

  describe 'given --api_key key' do
    it { is_expected.to have_run '[info] Authenticating via api token ...' }
    it { is_expected.to have_run 'ey-core whoami' }
    it { is_expected.to have_run '[info] Authenticated as dpl-test@travis-ci.org' }
    it { is_expected.to have_run '[info] Setting the build environment up for the deployment' }
    it { is_expected.to have_run '[info] Checking environment ...' }
    it { is_expected.to have_run 'ey-core environments' }
    it { is_expected.to have_run '[info] Deploying ...' }
    it { is_expected.to have_run '[info] $ ey-core deploy --ref="sha" --environment="env" --app="dpl" --no-migrate' }
    it { is_expected.to have_run 'ey-core deploy --ref="sha" --environment="env" --app="dpl" --no-migrate' }
    it { is_expected.to have_written '~/.ey-core', 'https://api.engineyard.com/: key' }
  end

  describe 'given --email email --password password' do
    let(:args) { |e| args_from_description(e) }

    it { is_expected.to have_run '[info] Authenticating via email and password ...' }
    it { is_expected.to have_run "ey-core login << str\nemail\npassword\nstr" }
  end

  describe 'no credentials', run: false do
    let(:args) { [] }

    it { expect { subject.run }.to raise_error 'Missing options: api_key, or email and password' }
  end

  describe 'given --app app' do
    it { is_expected.to have_run 'ey-core deploy --ref="sha" --environment="env" --app="app" --no-migrate' }
  end

  describe 'given --env other' do
    it { is_expected.to have_run 'ey-core deploy --ref="sha" --environment="other" --app="dpl" --no-migrate' }
  end

  describe 'given --account account' do
    it { is_expected.to have_run 'ey-core deploy --ref="sha" --environment="env" --app="dpl" --account="account" --no-migrate' }
  end

  describe 'given --migrate cmd' do
    it { is_expected.to have_run 'ey-core deploy --ref="sha" --environment="env" --app="dpl" --migrate="cmd"' }
  end

  describe 'no env matches', run: false do
    let(:envs) { '' }

    it { expect { subject.run }.to raise_error /No matching environment found/ }
  end

  describe 'multiple envs match', run: false do
    let(:envs) do
      <<-STR.gsub(/^\s+/, '')
        ID | Name | Account
        ---|------|-----------
        1  | one  | account
        2  | two  | account
      STR
    end

    it { expect { subject.run }.to raise_error 'Multiple environments match, please be more specific: environment=one account=account, environment=two account=account' }
  end

  describe 'with EY credentials in env vars', run: false do
    let(:args) { [] }

    env EY_API_KEY: 'key'
    it { expect { subject.run }.not_to raise_error }
  end

  describe 'with ENGINEYARD credentials in env vars', run: false do
    let(:args) { [] }

    env ENGINEYARD_API_KEY: 'key'
    it { expect { subject.run }.not_to raise_error }
  end
end
