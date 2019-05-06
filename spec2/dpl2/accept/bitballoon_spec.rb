describe Dpl::Provider::BitBalloon, 'acceptance' do
  before { subject.run }

  describe 'by default' do
    it { should have_run 'bitballoon deploy .' }
  end

  describe 'given --local_dir ./dir' do
    it { should have_run 'bitballoon deploy ./dir' }
  end

  describe 'given --site_id id' do
    it { should have_run 'bitballoon deploy . --site-id=id' }
  end

  describe 'given --access_token token' do
    it { should have_run 'bitballoon deploy . --access-token=token' }
  end

  describe 'given --local_dir ./dir --site_id id --access_token token' do
    it { should have_run 'bitballoon deploy ./dir --site-id=id --access-token=token' }
  end

  describe 'given --local-dir ./dir --site-id id --access-token token' do
    it { should have_run 'bitballoon deploy ./dir --site-id=id --access-token=token' }
  end
end
