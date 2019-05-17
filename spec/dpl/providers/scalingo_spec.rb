describe Dpl::Providers::Scalingo do
  let(:args) { |e| args_from_description(e) }

  describe 'invalid credentials' do
    it { expect { subject.run }.to raise_error 'Missing options: api_key, or username and password' }
  end

  context do
    before { subject.run }

    describe 'given --api_key key', record: true do
      it { should have_run %r(curl -OL https://cli-dl.scalingo.io/release/scalingo_latest_linux_amd64.tar.gz) }
      it { should have_run %r(./scalingo login --api-token key) }
      it { should have_run './scalingo keys-add dpl_tmp_key .dpl/id_rsa.pub' }
      it { should have_run 'git push scalingo master -f' }
      it { should have_run './scalingo keys-remove dpl_tmp_key' }
      it { should have_run_in_order }
    end

    describe 'given --username user --password pass', record: true do
      it { should have_run %r(curl -OL https://cli-dl.scalingo.io/release/scalingo_latest_linux_amd64.tar.gz) }
      it { should have_run %r(./scalingo login) }
      it { should have_run './scalingo keys-add dpl_tmp_key .dpl/id_rsa.pub' }
      it { should have_run 'git push scalingo master -f' }
      it { should have_run './scalingo keys-remove dpl_tmp_key' }
      it { should have_run_in_order }
    end
  end

  context do
    let(:args) { |e| %w(--api_key key) + args_from_description(e) }
    before { subject.run }

    describe 'given --branch branch' do
      before { subject.run }
      it { should have_run 'git push scalingo branch -f' }
    end

    describe 'given --app app' do
      before { subject.run }
      it { should have_run %r(git remote add scalingo git@scalingo.com:app.git) }
    end

    describe 'given --app app --remote name' do
      before { subject.run }
      it { should have_run %r(git remote add name git@scalingo.com:app.git) }
    end
  end
end

