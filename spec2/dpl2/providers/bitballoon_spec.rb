describe Dpl::Providers::BitBalloon do
  let(:args) { |e| %w(--access_token token --site_id id) + args_from_description(e) }

  before { subject.run }

  describe 'by default' do
    it { should have_run 'bitballoon deploy . --site-id="id" --access-token="token"' }
  end

  describe 'given --local_dir ./dir' do
    it { should have_run 'bitballoon deploy ./dir --site-id="id" --access-token="token"' }
  end
end
