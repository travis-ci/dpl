describe Dpl::Cli do
  let(:cli) { described_class.new(ctx) }
  subject { |e| cli.normalize(e.example_group.description.split(' ')) }

  describe 'heroku --strategy=api --api_key=key' do
    it { should eq %w(heroku api --api_key=key) }
  end

  describe 'heroku --strategy api --api_key key' do
    it { should eq %w(heroku api --api_key key) }
  end

  describe '--provider=heroku --strategy=api --api_key=key' do
    it { should eq %w(heroku api --api_key=key) }
  end

  describe '--provider heroku --strategy api --api_key key' do
    it { should eq %w(heroku api --api_key key) }
  end

  describe '--api_key=key --provider=heroku --strategy=api' do
    it { should eq %w(heroku api --api_key=key) }
  end

  describe '--api_key key --provider heroku --strategy api' do
    it { should eq %w(heroku api --api_key key) }
  end
end
