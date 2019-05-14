describe Dpl::Providers::Transifex, fakefs: true do
  let(:args) { |e| %w(--username user --password pass) + args_from_description(e) }
  let(:rc)   { File.read(File.expand_path('~/.transifexrc')) }

  dir File.expand_path('~')

  before { subject.run }

  describe 'by default', record: true do
    it { should have_run '[pip:install] transifex (transifex, >=0.11)' }
    it { should have_run 'tx status' }
    it { should have_run 'tx push --source --no-interactive' }
    it { should have_run_in_order }

    it do
      expect(rc).to eq <<~rc
        [https://www.transifex.com]
        hostname = https://www.transifex.com
        username = user
        password = pass
      rc
    end
  end

  describe 'given --cli_version >=0.22' do
    it { should have_run '[pip:install] transifex (transifex, >=0.22)' }
  end

  describe 'given --hostname other.com' do
    it { expect(rc).to include 'hostname = https://other.com' }
  end

  describe 'given --hostname https://other.com' do
    it { expect(rc).to include 'hostname = https://other.com' }
  end
end

