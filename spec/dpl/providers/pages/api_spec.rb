describe Dpl::Providers::Pages::Api do
  let(:args)    { |e| %w(--strategy api --github_token token) + args_from_description(e) }
  let(:user)    { JSON.dump(login: 'login', name: 'name', email: 'email') }
  let(:headers) { { 'Content-Type': 'application/json', 'X-OAuth-Scopes': ['repo'] } }
  let(:cwd)     { File.expand_path('.') }
  let(:tmp)     { File.expand_path('tmp') }

  before { stub_request(:get, 'https://api.github.com/user').and_return(status: 200, body: user, headers: headers) }

  before { subject.run }

  describe 'by default', record: true do
    it { should have_run '[info] Logged in as login (name)' }
    it { should have_run_in_order }
  end
end
