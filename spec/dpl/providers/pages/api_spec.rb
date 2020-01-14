describe Dpl::Providers::Pages do
  let(:args)    { |e| %w(--strategy api --github_token token) + args_from_description(e) }
  let(:user)    { JSON.dump(login: 'login', name: 'name', email: 'email') }
  let(:headers) { { 'Content-Type': 'application/json', 'X-OAuth-Scopes': ['repo'] } }
  let(:cwd)     { File.expand_path('.') }
  let(:tmp)     { File.expand_path('tmp') }

  let(:pages_response_body) {
    {
      "url": "https://api.github.com/repos/travis-ci/dpl/pages",
      "status": "built",
      "cname": "about.travis-ci.org",
      "custom_404": false,
      "html_url": "https://about.travis-ci.org/dpl",
      "source": {
        "branch": "gh-pages",
        "directory": "/"
      }
    }.to_json
  }

  let(:pages_latest_builds_response_body) {
    {
      "url": "https://api.github.com/repos/travis-ci/dpl/pages/builds/5472601",
      "status": "built",
      "error": {
        "message": nil
      },
      "pusher": {
        login: 'login',
        name: 'name',
        email: 'email'
      },
      "commit": "351391cdcb88ffae71ec3028c91f375a8036a26b",
      "duration": 2104,
      "created_at": "2019-02-10T19:00:49Z",
      "updated_at": "2019-02-10T19:00:51Z"
    }.to_json
  }

  let(:pages_build_request_response_body) {
    {
      "url": "https://api.github.com/repos/travis-ci/dpl/pages/builds/latest",
      "status": "queued"
    }.to_json
  }

  before { stub_request(:get, 'https://api.github.com/user').and_return(status: 200, body: user, headers: headers) }
  before { stub_request(:get, 'https://api.github.com/repos/travis-ci/dpl/pages').and_return(status: 200, body: pages_response_body, headers: headers) }
  before { stub_request(:get, 'https://api.github.com/repos/travis-ci/dpl/pages/builds/latest').and_return(status: 200, body: pages_latest_builds_response_body, headers: headers) }
  before { stub_request(:post, 'https://api.github.com/repos/travis-ci/dpl/pages/builds').and_return(status: 200, body: pages_build_request_response_body, headers: headers) }

  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    it { should have_run_in_order }
  end

  describe 'with GITHUB credentials in env vars', run: false do
    let(:args) { %w(--strategy api) }
    env GITHUB_TOKEN: 'token'
    it { expect { subject.run }.to_not raise_error }
  end

  describe 'with PAGES credentials in env vars', run: false do
    let(:args) { %w(--strategy api) }
    env PAGES_TOKEN: 'token'
    it { expect { subject.run }.to_not raise_error }
  end
end
