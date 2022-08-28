describe Dpl::Providers::Snap do
  let(:args) { |e| args_from_description(e) + %w(--token token) }

  file 'snap'

  before { |c| subject.run if run?(c) }

  describe 'given --snap ./snap', record: true do
    it { should have_run '[apt:get] snapd (snap)' }
    it { should have_run 'sudo snap install snapcraft --classic' }
    it { should have_run 'echo "token" | snapcraft login --with -' }
    it { should have_run 'snapcraft upload ./snap --release=edge' }
    it { should have_run_in_order }
  end

  describe 'given --snap ./sn*' do
    it { should have_run 'snapcraft upload ./snap --release=edge' }
  end

  describe 'given --snap ./snap --channel channel' do
    it { should have_run 'snapcraft upload ./snap --release=channel' }
  end

  describe 'given --snap ./snap', run: false do
    let(:args) { |e| args_from_description(e) }

    env SNAP_TOKEN: 'token'

    before { subject.run }
    it { should have_run 'echo "token" | snapcraft login --with -' }
  end

  describe 'given --snap ./snap', run: false do
    before { rm 'snap' }
    it { expect { subject.run }.to raise_error 'No snap found matching ./snap' }
  end

  describe 'given --snap ./sn*', run: false do
    file 'snap-1'
    file 'snap-2'
    it { expect { subject.run }.to raise_error 'Multiple snaps found matching ./sn*: ./snap, ./snap-1, ./snap-2' }
  end

  describe 'with credentials in env vars', run: false do
    let(:args) { %w(--snap ./snap) }
    env SNAP_TOKEN: 'token'
    it { expect { subject.run }.to_not raise_error }
  end
end
