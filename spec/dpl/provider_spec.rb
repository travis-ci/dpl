# frozen_string_literal: true

describe :test do
  let!(:const) { Class.new(Dpl::Provider, &body) }

  before { const.register :test }

  describe 'fails during deployment' do
    let(:body) { ->(*) { def deploy = error('msg') } }

    it { expect { subject.run }.to raise_error(Dpl::Error, 'msg') }
  end
end
