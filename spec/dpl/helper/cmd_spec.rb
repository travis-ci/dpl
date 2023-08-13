# frozen_string_literal: true

describe Dpl::Cmd do
  subject(:dpl_cmd) { described_class.new(provider, cmd, opts) }

  let(:provider) { Class.new(Dpl::Provider, &body).new(ctx, []) }
  let(:body) { ->(*) {} }
  let(:opts) { {} }
  let(:cmd)  {}

  describe 'cmd' do
    describe 'given a str, interpolating opts' do
      let(:opts) { { var: :var } }
      let(:cmd) { 'cmd %{var}' }

      it { expect(dpl_cmd.cmd).to eq 'cmd var' }
    end

    describe 'given a symbol, with the cmd mapping present' do
      let(:cmd) { :cmd }

      describe 'interpolating an opt' do
        let(:body) { ->(*) { cmds cmd: 'cmd %{var}' } }
        let(:opts) { { var: :var } }

        it { expect(dpl_cmd.cmd).to eq 'cmd var' }
      end

      describe 'interpolating a secure opt' do
        let(:body) do
          lambda { |*|
            cmds cmd: 'cmd %{var}'
            opt '--var', secret: true
          }
        end
        let(:opts) { { var: 'secure' } }

        it { expect(dpl_cmd.cmd).to eq 'cmd secure' }
      end

      describe 'interpolating a method' do
        let(:body) do
          lambda { |*|
            cmds cmd: 'cmd %{var}'
            def var = 'var'
          }
        end

        it { expect(dpl_cmd.cmd).to eq 'cmd var' }
      end

      describe 'interpolating a const' do
        let(:body) do
          lambda { |c|
            cmds cmd: 'cmd %{VAR}'
            c.const_set(:VAR, 'var')
          }
        end

        it { expect(dpl_cmd.cmd).to eq 'cmd var' }
      end
    end

    describe 'given a symbol, with the cmd mapping missing' do
      let(:body) { ->(*) {} }
      let(:cmd) { :cmd }

      it { expect { dpl_cmd.cmd }.to raise_error 'Could not find cmd: :cmd' }
    end
  end

  describe 'msg' do
    describe 'given a msg, interpolating opts' do
      let(:opts) { { msg: 'msg %{var}', var: :var } }

      it { expect(dpl_cmd.msg).to eq 'msg var' }
    end

    describe 'given a symbol, with the cmd mapping missing' do
      let(:body) { ->(*) {} }
      let(:cmd) { :cmd }

      it { expect { dpl_cmd.msg }.to raise_error 'Could not find msg: :cmd' }
    end
  end

  describe 'error' do
    describe 'by default' do
      it { expect(dpl_cmd.error).to eq 'Failed' }
    end

    describe 'given assert: :err, mapping present' do
      let(:body) { ->(*) { errs err: 'err %{var}' } }
      let(:opts) { { assert: :err, var: :var } }

      it { expect(dpl_cmd.error).to eq 'err var' }
    end

    describe 'given assert: :err, mapping missing' do
      let(:opts) { { assert: :err } }

      it { expect(dpl_cmd.error).to eq 'Failed' }
    end

    describe 'given cmd: :cmd, mapping present' do
      let(:body) do
        lambda { |*|
          cmds cmd: 'cmd'
          errs cmd: 'err %{var}'
        }
      end
      let(:opts) { { var: :var } }
      let(:cmd) { :cmd }

      it { expect(dpl_cmd.error).to eq 'err var' }
    end
  end

  describe 'assert?' do
    describe 'defaults to true' do
      it { expect(dpl_cmd).to be_assert }
    end

    describe 'given true' do
      let(:opts) { { assert: true } }

      it { expect(dpl_cmd).to be_assert }
    end

    describe 'given false' do
      let(:opts) { { assert: false } }

      it { expect(dpl_cmd).not_to be_assert }
    end
  end
end
