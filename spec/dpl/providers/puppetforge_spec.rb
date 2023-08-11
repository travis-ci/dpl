# frozen_string_literal: true

describe Dpl::Providers::Puppetforge do
  let(:args) { |e| %w[--username user --password pass] + args_from_description(e) }
  let(:face)  { double(build: nil) }
  let(:forge) { double(username: 'user', push!: nil) }

  file 'metadata.json', JSON.dump(name: 'author-module')

  before { allow(Blacksmith::Forge).to receive(:new).and_return(forge) }
  before { allow(Puppet::Face).to receive(:[]).and_return(face) }
  before { |c| subject.run if run?(c) }

  describe 'by default' do
    it { is_expected.to have_run '[info] Uploading to Puppet Forge user/module' }
    it { expect(Blacksmith::Forge).to have_received(:new).with('user', 'pass', 'https://forgeapi.puppetlabs.com/') }
    it { expect(forge).to have_received :push! }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { [] }

    env PUPPETFORGE_USERNAME: 'user',
        PUPPETFORGE_PASSWORD: 'pass'
    it { expect { subject.run }.not_to raise_error }
  end
end
