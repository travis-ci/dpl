describe Dpl::Providers::Firebase do
  let(:args) { |e| %w(--token token) + args_from_description(e) }

  file 'firebase.json'

  before { |c| subject.run if run?(c) }

  describe 'by default' do
    it { should have_run '[npm:install] firebase-tools@^6.3 (firebase)' }
    it { should have_run 'firebase deploy --non-interactive --token="token"' }
  end

  describe 'given --project name' do
    it { should have_run 'firebase deploy --non-interactive --project="name" --token="token"' }
  end

  describe 'given --message msg' do
    it { should have_run 'firebase deploy --non-interactive --message="msg" --token="token"' }
  end

  describe 'given --only only' do
    it { should have_run 'firebase deploy --non-interactive --token="token" --only="only"' }
  end

  describe 'given --force' do
    it { should have_run 'firebase deploy --non-interactive --token="token" --force' }
  end

  describe 'missing firebase.json', run: false do
    before { rm 'firebase.json' }
    it { expect { subject.run }.to raise_error 'Missing firebase.json' }
  end

  describe 'adds node_modules/.bin to $PATH' do
    it { expect(ENV['PATH']).to include 'node_modules/.bin' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { [] }
    env FIREBASE_TOKEN: 'token'
    it { expect { subject.run }.to_not raise_error }
  end
end
