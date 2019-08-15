describe Dpl::Interpolate do
  let(:provider) { Class.new(Dpl::Provider, &body).new(ctx, %w(--password secret)) }
  let(:body) { ->(*) { opt '--password PASS', secret: true } }
  let(:str)  { 'string containing secret' }
  let(:args) { [] }
  let(:opts) { {} }

  subject { provider.interpolate(str, args, opts) }

  describe 'obj accessor' do
    it { should eq 'string containing s*******************' }
  end

  describe 'passing args as an array' do
    let(:args) { ['one'] }
    it { should eq 'string containing s*******************' }
  end

  describe 'given secure: true' do
    let(:opts) { { secure: true } }
    it { should eq 'string containing secret' }
  end
end
