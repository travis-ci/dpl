describe Dpl::Providers::Rubygems do
  let(:args) { |e| args_from_description(e) }
  let(:name) { 'dpl' }

  file 'dpl.gemspec'
  file 'dpl-2.0.0.gem', 'dpl'
  file 'other.gemspec'
  file 'other-0.0.1.gem', 'other'

  before { stub_request(:get, %r(/gems/.+json)).and_return(body: JSON.dump(name: name)) }
  before { stub_request(:post, %r(/gems)).and_return(body: "Successfully registered gem: #{name}") }
  before { |c| subject.run if run?(c) }

  describe 'given --api_key 1234', record: true do
    it { should have_run '[info] Authenticating with api key 1*******************' }
    it { should have_run '[print] Looking up gem dpl ... ' }
    it { should have_run '[info] found.' }
    it { should have_run 'gem build dpl.gemspec' }
    it { should have_run '[info] Successfully registered gem: dpl' }
    it { should have_requested(:get, %r(/gems/dpl.json)) }
    it { should have_requested(:post, %r(/gems)).with(body: 'dpl') }
    it { should have_run_in_order }
    it { should_not have_run 'gem build other.gemspec' }
  end

  describe 'given --user user --password 1234' do
    it { should have_run '[info] Authenticating with username user and password 1*******************' }
  end

  context do
    let(:args) { |e| %w(--api_key key) + args_from_description(e) }

    describe 'given --gem other' do
      let(:name) { 'other' }
      it { should have_run '[print] Looking up gem other ... ' }
      it { should_not have_run 'gem build dpl.gemspec' }
      it { should have_run 'gem build other.gemspec' }
      it { should have_run '[info] Successfully registered gem: other' }
      it { should have_requested(:get, %r(/gems/other.json)) }
      it { should have_requested(:post, %r(/gems)).with(body: 'other') }
    end

    describe 'given --gemspec other.gemspec' do
      it { should_not have_run 'gem build dpl.gemspec' }
      it { should have_run 'gem build other.gemspec' }
    end

    describe 'given --gemspec_glob *.gemspec' do
      it { should have_run 'gem build dpl.gemspec' }
      it { should have_run 'gem build other.gemspec' }
    end

    describe 'given --host https://host.com' do
      it { should have_requested(:get, 'https://host.com/api/v1/gems/dpl.json') }
      it { should have_requested(:post, 'https://host.com/api/v1/gems') }
    end
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { [] }
    env RUBYGEMS_API_KEY: '1234'
    it { expect { subject.run }.to_not raise_error }
  end
end
