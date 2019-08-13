describe Dpl::Providers::Gcs::Gcs do
  let(:args) { |e| %w(--strategy gcs --bucket bucket --project_id foo-bar-12345 --credentials creds.json) + args_from_description(e) }
  
  before { stub_request(:put, /.*/) }
  before { subject.run }

  describe 'by default', record: true do
    it { should have_run_in_order }
  end

end
