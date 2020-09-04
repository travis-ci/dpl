describe Dpl::Cmd do
  let(:provider) { Class.new(Dpl::Provider, &body).new(ctx, []) }
  let(:body) { ->(*) {} }
  let(:opts) { {} }
  let(:cmd)  {}

  subject { described_class.new(provider, cmd, opts) }

  describe 'cmd' do
    describe 'given a str, interpolating opts' do
      let(:opts) { { var: :var } }
      let(:cmd) { 'cmd %{var}' }
      it { expect(subject.cmd).to eq 'cmd var' }
    end

    describe 'given a symbol, with the cmd mapping present' do
      let(:cmd) { :cmd }

      describe 'interpolating an opt' do
        let(:body) { ->(*) { cmds cmd: 'cmd %{var}' } }
        let(:opts) { { var: :var } }
        it { expect(subject.cmd).to eq 'cmd var' }
      end

      describe 'interpolating a secure opt' do
        let(:body) { ->(*) { cmds cmd: 'cmd %{var}'; opt '--var', secret: true } }
        let(:opts) { { var: 'secure' } }
        it { expect(subject.cmd).to eq 'cmd secure' }
      end

      describe 'interpolating a method' do
        let(:body) { ->(*) { cmds cmd: 'cmd %{var}'; def var; 'var'; end } }
        it { expect(subject.cmd).to eq 'cmd var' }
      end

      describe 'interpolating a const' do
        let(:body) { ->(c) { cmds cmd: 'cmd %{VAR}'; c.const_set(:VAR, 'var') } }
        it { expect(subject.cmd).to eq 'cmd var' }
      end
    end

    describe 'given a symbol, with the cmd mapping missing' do
      let(:body) { ->(*) {} }
      let(:cmd) { :cmd }
      it { expect { subject.cmd }.to raise_error 'Could not find cmd: :cmd' }
    end
  end

  describe 'msg' do
    describe 'given a msg, interpolating opts' do
      let(:opts) { { msg: 'msg %{var}', var: :var } }
      it { expect(subject.msg).to eq 'msg var' }
    end

    describe 'given a symbol, with the cmd mapping missing' do
      let(:body) { ->(*) {} }
      let(:cmd) { :cmd }
      it { expect { subject.msg }.to raise_error 'Could not find msg: :cmd' }
    end
  end

  describe 'error' do
    describe 'by default' do
      it { expect(subject.error).to eq 'Failed' }
    end

    describe 'given assert: :err, mapping present' do
      let(:body) { ->(*) { errs err: 'err %{var}' } }
      let(:opts) { { assert: :err, var: :var } }
      it { expect(subject.error).to eq 'err var' }
    end

    describe 'given assert: :err, mapping missing' do
      let(:opts) { { assert: :err } }
      it { expect(subject.error).to eq 'Failed' }
    end

    describe 'given cmd: :cmd, mapping present' do
      let(:body) { ->(*) { cmds cmd: 'cmd'; errs cmd: 'err %{var}' } }
      let(:opts) { { var: :var } }
      let(:cmd) { :cmd }
      it { expect(subject.error).to eq 'err var' }
    end
  end

  describe 'assert?' do
    describe 'defaults to true' do
      it { expect(subject).to be_assert }
    end

    describe 'given true' do
      let(:opts) { { assert: true } }
      it { expect(subject).to be_assert }
    end

    describe 'given false' do
      let(:opts) { { assert: false } }
      it { expect(subject).to_not be_assert }
    end
  end
end
