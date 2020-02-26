describe Dpl::Providers::Nuget do
  let(:args) { |e| %w(--api_key secret --registry url) + args_from_description(e) }

  before { subject.run }

  describe 'by default', record: true do
     it { should have_run '[info] Setting the build environment up for the deployment' }
     it { should have_run '[info] Authenticating with API key s*******************' }
     it { should have_run '[info] Pushing package *.nupkg to url' }
     it { should have_run '[info] $ dotnet nuget push *.nupkg -k s******************* -s url' }
     it { should have_run 'dotnet nuget push *.nupkg -k secret -s url' }
    it { should have_run_in_order }
  end

  describe 'given --src other.nupkg' do
     it { should have_run 'dotnet nuget push other.nupkg -k secret -s url' }
  end

  describe 'given --no_symbols' do
     it { should have_run 'dotnet nuget push *.nupkg -k secret -s url --no-symbols' }
  end

  describe 'given --skip_duplicate' do
     it { should have_run 'dotnet nuget push *.nupkg -k secret -s url --skip-duplicate' }
  end
end
