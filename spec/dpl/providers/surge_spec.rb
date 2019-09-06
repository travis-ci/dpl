describe Dpl::Providers::Surge do
  let(:args) { |e| args_from_description(e) }
  let(:cwd)  { File.expand_path('.') }

  before { stub_request(:get, %r(npmjs.com/surge/latest)).to_return(body: '{"_nodeVersion": "8.8.0"}') }

  describe 'given --login login --token token --domain domain', record: true do
    before { subject.run }
    it { should have_run '[validate:runtime] node_js (>= 8.8.1)' }
    it { should have_run '[npm:install] surge (surge)' }
    it { should have_run "surge #{cwd} domain" }
    it { should have_run_in_order }
    it { should have_env SURGE_LOGIN: 'login' }
    it { should have_env SURGE_TOKEN: 'token' }
  end

  describe 'given --login login --token token' do
    file :CNAME
    before { subject.run }
    it { should have_run "surge #{cwd}" }
  end

  describe 'given --login login --token token' do
    it { expect { subject.run }.to raise_error /Please set the domain/ }
  end

  describe 'given --login login --token token --domain domain --project ./path' do
    dir 'path'
    before { subject.run }
    it { should have_run "surge #{cwd}/path domain" }
  end

  describe 'given --login login --token token --domain domain --project ./path' do
    it { expect { subject.run }.to raise_error "#{cwd}/path is not a directory" }
  end

  describe 'given --domain domain' do
    env SURGE_LOGIN: 'login', SURGE_TOKEN: 'token'
    before { subject.run }
    it { should have_run "surge #{cwd} domain" }
  end
end
