describe Dpl::Providers::Scalingo do
  let(:args) { |e| args_from_description(e) }

  describe 'invalid credentials' do
    it { expect { subject.run }.to raise_error 'Missing options: api_key, or username and password' }
  end

  context do
    before { subject.run }

    describe 'given --api_key key', record: true do
      it { should have_run %r(curl --remote-name --location https://cli-dl.scalingo.io/release/scalingo_latest_linux_amd64.tar.gz) }
      it { should have_run %r(timeout 60 ./scalingo login --api-token key) }
      it { should have_run 'timeout 60 ./scalingo keys-add dpl_tmp_key .dpl/id_rsa.pub' }
      it { should have_run 'git push scalingo-dpl HEAD:master -f' }
      it { should have_run 'timeout 60 ./scalingo keys-remove dpl_tmp_key' }
      it { should have_run_in_order }
    end

    describe 'given --username user --password pass', record: true do
      it { should have_run %r(echo -e "user\npass" | timeout 60 ./scalingo login) }
    end
  end

  context do
    let(:args) { |e| %w(--api_key key) + args_from_description(e) }
    before { subject.run }

    describe 'given --branch branch' do
      before { subject.run }
      it { should have_run 'git push scalingo-dpl HEAD:branch -f' }
    end

    describe 'given --app app' do
      before { subject.run }
      it { should have_run %r(./scalingo --app app git-setup --remote scalingo-dpl) }
    end

    describe 'given --app app --remote remote' do
      before { subject.run }
      it { should have_run %r(./scalingo --app app git-setup --remote remote) }
    end
  end
end

