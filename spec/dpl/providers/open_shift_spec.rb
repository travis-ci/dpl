describe Dpl::Providers::OpenShift do
  let(:args) { |e| %w(--user user --password pass --domain domain) + args_from_description(e) }

  let(:user) { double(login: 'foo@bar.com') }
  let(:app)  { double(name: 'dpl', git_url: 'git://dpl.git', 'deployment_branch=': nil, restart: nil) }
  let(:api)  { double(user: user, find_application: app, add_key: nil, delete_key: nil) }

  before { expect(RHC::Rest::Client).to receive(:new).with(user: 'user', password: 'pass', server: 'openshift.redhat.com').and_return(api) }
  before { subject.run }

  describe 'by default', record: true do
    it { should have_run '[info] Authenticated as user' }
    it { should have_run '[info] Found application dpl' }
    it { should have_run 'git push git://dpl.git -f' }
    it { should have_run_in_order }
    it { expect(api).to have_received(:find_application).with('domain', 'dpl') }
    it { expect(api).to have_received(:add_key).with('machine_name', 'public-key', 'ssh-rsa') }
    it { expect(api).to have_received(:delete_key).with('machine_name') }
  end

  describe 'given --app other' do
    it { expect(api).to have_received(:find_application).with('domain', 'other') }
  end

  describe 'given --deployment_branch branch' do
    it { should have_run '[info] Deployment branch: branch' }
    it { should have_run 'git push git://dpl.git -f branch' }
  end

  describe 'given --run restart' do
    it { expect(app).to have_received(:restart) }
  end
end
