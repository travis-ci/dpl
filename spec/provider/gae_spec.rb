require 'spec_helper'
require 'dpl/provider/gae'

describe DPL::Provider::GAE do
  subject :provider do
    described_class.new(DummyContext.new, project: 'test')
  end

  describe '#push_app' do
    example 'with defaults' do
      expect(provider.context).to receive(:shell).with("#{DPL::Provider::GAE::GCLOUD} --quiet --verbosity \"warning\" --project \"test\" preview app deploy \"app.yaml\" --version \"\" --docker-build \"remote\"").and_return(true)
      provider.push_app
    end
  end
end
