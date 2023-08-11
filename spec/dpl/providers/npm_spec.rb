# frozen_string_literal: true

describe Dpl::Providers::Npm do
  let(:args) { |e| %w(--email email --api_key 12345) + args_from_description(e) }
  let(:npmrc_1) { "_auth = 12345\nemail = email" }
  let(:npmrc_2) { '//registry.npmjs.org/:_authToken=12345' }

  before { allow(ctx).to receive(:npm_version).and_return(npm_version) if defined?(npm_version) }
  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    it { is_expected.to have_run '[info] npm version: 1' }
    it { is_expected.to have_run '[info] Authenticated with API token 1*******************' }
    it { is_expected.to have_run '[info] ~/.npmrc size: 27' }
    it { is_expected.to have_run 'npm config set registry "https://registry.npmjs.org"' }
    it { is_expected.to have_run 'npm publish .' }
    it { is_expected.to have_run_in_order }
  end

  describe 'given --src ./dir' do
    it { is_expected.to have_run 'npm publish ./dir' }
  end

  describe 'given --access public' do
    it { is_expected.to have_run 'npm publish . --access="public"' }
  end

  describe 'given --tag tag' do
    it { is_expected.to have_run 'npm publish . --tag="tag"' }
  end

  describe 'given --run_script one --run_script two' do
    it { is_expected.to have_run 'npm run one' }
    it { is_expected.to have_run 'npm run two' }
  end

  describe 'npm_version 6, given --dry-run' do
    let(:npm_version) { '6' }

    it { is_expected.to have_run 'npm publish . --dry-run' }
  end


  describe 'npm_version 1' do
    let(:npm_version) { '1' }

    it { is_expected.to have_written '~/.npmrc', npmrc_1 }
  end

  describe 'npm_version 2' do
    let(:npm_version) { '2' }

    it { is_expected.to have_written '~/.npmrc', npmrc_2 }

    describe 'given --registry https://npm.pkg.github.com/owner' do
      let(:npmrc) { '//npm.pkg.github.com/:_authToken=12345' }

      it { is_expected.to have_run 'npm config set registry "https://npm.pkg.github.com/owner"' }
      it { is_expected.to have_written '~/.npmrc', npmrc }
    end

    describe 'given --registry https://www.myget.org/F/owner/npm/' do
      let(:npmrc) { '//www.myget.org/F/owner/npm/:_authToken=12345' }

      it { is_expected.to have_run 'npm config set registry "https://www.myget.org/F/owner/npm/"' }
      it { is_expected.to have_written '~/.npmrc', npmrc }
    end
  end

  describe 'npm_version 2, given --auth_method auth' do
    let(:npm_version) { '2' }

    it { is_expected.to have_written '~/.npmrc', npmrc_1 }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { %w(--email email) }

    env NPM_API_TOKEN: '12345'
    it { expect { subject.run }.not_to raise_error }
  end

  describe 'with credentials in env vars (alias)', run: false do
    let(:args) { %w(--email email) }

    env NPM_API_KEY: '12345'
    it { expect { subject.run }.not_to raise_error }
  end
end
