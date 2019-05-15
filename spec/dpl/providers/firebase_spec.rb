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
  end

  describe 'missing firebase.json' do
    it { expect { subject.run }.to raise_error 'Missing firebase.json' }
  end
end
