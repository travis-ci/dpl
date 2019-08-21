describe Dpl::Providers::Firebase do
  let(:args) { |e| %w(--token token) + args_from_description(e) }

  context do
    file 'firebase.json'
    before { subject.run }

    describe 'by default' do
      it { should have_run '[npm:install] firebase-tools@^6.3 (firebase)' }
      it { should have_run 'firebase deploy --non-interactive --token="token"' }
    end

    describe 'given --project name' do
      before { subject.run }
      it { should have_run 'firebase deploy --non-interactive --project="name" --token="token"' }
    end

    describe 'given --message msg' do
      before { subject.run }
      it { should have_run 'firebase deploy --non-interactive --message="msg" --token="token"' }
    end

    describe 'given --only only' do
      before { subject.run }
      it { should have_run 'firebase deploy --non-interactive --token="token" --only="only"' }
    end

    describe 'given --force' do
      before { subject.run }
      it { should have_run 'firebase deploy --non-interactive --token="token" --force' }
    end
  end

  describe 'missing firebase.json' do
    it { expect { subject.run }.to raise_error 'Missing firebase.json' }
  end

  describe 'adds node_modules/.bin to $PATH' do
    it { expect(ENV['PATH']).to include 'node_modules/.bin' }
  end
end
