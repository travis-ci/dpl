describe Dpl::Providers::Scalingo do
  let(:args) { |e| args_from_description(e) }

  before { |c| subject.run if run?(c) }

  describe 'given --api_token token', record: true do
    it { should have_run %r(curl --remote-name --location https://cli-dl.scalingo.io/release/scalingo_latest_linux_amd64.tar.gz) }
    it { should have_run %r(timeout 60 ./scalingo login --api-token token) }
    it { should have_run 'timeout 60 ./scalingo keys-add dpl_tmp_key ~/.dpl/id_rsa.pub' }
    it { should have_run 'git fetch origin --unshallow' }
    it { should have_run 'git push scalingo-dpl HEAD:refs/heads/master -f' }
    it { should have_run 'timeout 60 ./scalingo keys-remove dpl_tmp_key' }
    it { should have_run_in_order }
  end

  describe 'given --api_key key' do
    it { should have_run %r(timeout 60 ./scalingo login --api-token key) }
  end

  describe 'given --username user --password pass', record: true do
    it { should have_run %r(echo -e "user\npass" | timeout 60 ./scalingo login) }
  end

  describe 'given --api_token key --app app' do
    it { should have_run %r(./scalingo --app app git-setup --remote scalingo-dpl) }
  end

  describe 'given --api_token key --app app --remote remote' do
    it { should have_run %r(./scalingo --app app git-setup --remote remote) }
  end

  describe 'given --api_token key --app app --deploy-method archive' do
    it { should have_run %r(git archive --prefix dpl-scalingo-deploy/ HEAD | gzip - > dpl-scalingo-deploy.tar.gz) }
    it { should have_run %r(./scalingo --app app deploy "dpl-scalingo-deploy.tar.gz" ".+") }
  end

  describe 'invalid credentials', run: false do
    it { expect { subject.run }.to raise_error 'Missing options: api_token, or username and password' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { [] }
    env SCALINGO_API_TOKEN: 'token'
    it { expect { subject.run }.to_not raise_error }
  end
end
