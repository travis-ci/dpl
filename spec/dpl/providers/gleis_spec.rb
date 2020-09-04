describe Dpl::Providers::Gleis do
  let(:args) { |e| %w(--app app --username user --password pass) + args_from_description(e) }

  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    it { should have_run '[info] $ gleis auth login user p******************* --skip-keygen' }
    it { should have_run 'gleis auth login user pass --skip-keygen' }
    it { should have_run '[info] $ gleis auth key add ~/.dpl/id_rsa.pub dpl_deploy_key' }
    it { should have_run 'gleis auth key add ~/.dpl/id_rsa.pub dpl_deploy_key' }
    it { should have_run '[info] $ gleis app git -a app -q' }
    it { should have_run 'gleis app git -a app -q' }
    it { should have_run '[info] $ gleis app status -a app' }
    it { should have_run 'gleis app status -a app' }
    it { should have_run '[info] $ git push -f captured_stdout HEAD:refs/heads/master' }
    it { should have_run 'git push -f captured_stdout HEAD:refs/heads/master' }
    it { should have_run_in_order }
  end

  describe 'given --key_name key_name' do
    it { should have_run '[info] $ gleis auth key add ~/.dpl/id_rsa.pub key_name' }
    it { should have_run 'gleis auth key add ~/.dpl/id_rsa.pub key_name' }
  end

  describe 'given --verbose' do
    it { should have_run 'git push -v -f captured_stdout HEAD:refs/heads/master' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { %w(--app app) }
    env GLEIS_USERNAME: 'user',
        GLEIS_PASSWORD: 'pass'
    it { expect { subject.run }.to_not raise_error }
  end
end
