describe Dpl::Providers::Transifex do
  let(:args) { |e| %w(--username user --password pass) + args_from_description(e) }
  let(:rc) { File.read('./home/.transifexrc') }

  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    it { should have_run '[pip:install] transifex-client (tx, >=0.11)' }
    it { should have_run 'tx status' }
    it { should have_run 'tx push --source --no-interactive' }
    it { should have_run_in_order }

    it do
      should have_written '~/.transifexrc', sq(<<-rc)
        [https://www.transifex.com]
        hostname = https://www.transifex.com
        username = user
        password = pass
      rc
    end
  end

  describe 'given --cli_version >=0.22' do
    it { should have_run '[pip:install] transifex-client (tx, >=0.22)' }
  end

  describe 'given --hostname other.com' do
    it { expect(rc).to include 'hostname = https://other.com' }
  end

  describe 'given --hostname https://other.com' do
    it { expect(rc).to include 'hostname = https://other.com' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { [] }
    env TRANSIFEX_USERNAME: 'user',
        TRANSIFEX_PASSWORD: 'pass'
    it { expect { subject.run }.to_not raise_error }
  end
end
