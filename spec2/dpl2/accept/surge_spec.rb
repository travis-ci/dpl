describe Dpl::Providers::Surge, 'acceptance' do
  let(:args) { |e| %w(--target target) + args_from_description(e) }

  before { subject.run }

  describe 'by default' do
    xit { should have_run 'cmd' }
  end
end

