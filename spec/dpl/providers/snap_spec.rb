describe Dpl::Providers::Snap do
  let(:args) { |e| args_from_description(e) + %w(--token token) }

  chdir 'tmp'

  context do
    file 'snap'
    before { subject.run }

    describe 'given --snap ./snap', record: true do
      it { should have_run '[apt:get] snapd (snap)' }
      it { should have_run 'sudo snap install snapcraft --classic' }
      it { should have_run 'snapcraft login --with token' }
      it { should have_run 'snapcraft push ./snap --release=edge' }
      it { should have_run_in_order }
    end

    describe 'given --snap ./sn*' do
      it { should have_run 'snapcraft push ./snap --release=edge' }
    end

    describe 'given --snap ./snap --channel channel' do
      it { should have_run 'snapcraft push ./snap --release=channel' }
    end
  end

  describe 'given --snap ./snap' do
    let(:args) { |e| args_from_description(e) }

    env SNAP_TOKEN: 'token'
    file 'snap'

    before { subject.run }
    it { should have_run 'snapcraft login --with token' }
  end

  describe 'given --snap ./snap' do
    it { expect { subject.run }.to raise_error 'No snap found matching ./snap' }
  end

  describe 'given --snap ./sn*' do
    file 'snap-1'
    file 'snap-2'
    it { expect { subject.run }.to raise_error 'Multiple snaps found matching ./sn*: ./snap-1, ./snap-2' }
  end
end
