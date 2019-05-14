describe Dpl::Providers::Rubygems do
  let(:args) { |e| args_from_description(e) }
  let(:name) { 'dpl' }

  chdir 'tmp'
  file 'dpl-2.0.0.gem', 'dpl'
  file 'other-0.0.1.gem', 'other'

  before { stub_request(:get, %r(/gems/.+json)).and_return(body: JSON.dump(name: name)) }
  before { stub_request(:post, %r(/gems)).and_return(body: "Successfully registered gem: #{name}") }
  before { subject.run }

  describe 'given --api_key key', record: true do
    it { should have_run '[info] Authenticating with api key.' }
    it { should have_run '[print] Looking up gem dpl ... ' }
    it { should have_run '[info] found.' }
    it { should have_run 'for gemspec in dpl.gemspec; do gem build $gemspec; done' }
    it { should have_run '[info] Successfully registered gem: dpl' }
    it { should have_requested(:get, %r(/gems/dpl.json)) }
    it { should have_requested(:post, %r(/gems)).with(body: 'dpl') }
    it { should have_run_in_order }
  end

  describe 'given --user user --password pass' do
    it { should have_run '[info] Authenticating with username user and password.' }
  end

  context do
    let(:args) { |e| %w(--api_key key) + args_from_description(e) }

    describe 'given --gem other' do
      let(:name) { 'other' }
      it { should have_run '[print] Looking up gem other ... ' }
      it { should have_run 'for gemspec in other.gemspec; do gem build $gemspec; done' }
      it { should have_run '[info] Successfully registered gem: other' }
      it { should have_requested(:get, %r(/gems/other.json)) }
      it { should have_requested(:post, %r(/gems)).with(body: 'other') }
    end

    describe 'given --gemspec other.gemspec' do
      it { should have_run 'for gemspec in other.gemspec; do gem build $gemspec; done' }
    end

    describe 'given --gemspec_glob *.gemspec' do
      it { should have_run 'for gemspec in *.gemspec; do gem build $gemspec; done' }
    end

    describe 'given --host https://host.com' do
      it { should have_requested(:get, 'https://host.com/api/v1/gems/dpl.json') }
      it { should have_requested(:post, 'https://host.com/api/v1/gems') }
    end
  end
end
