# frozen_string_literal: true

describe Dpl::Providers::Cloud66 do
  let(:url) { 'https://hook.io/' }

  before { stub_request(:post, url).to_return(status: 200) }
  before { |c| subject.run if run?(c) }

  describe 'given --redeployment_hook https://hook.io/' do
    it { assert_requested :post, url }
  end

  describe 'with credentials in env vars', run: false do
    env CLOUD66_REDEPLOYMENT_HOOK: 'https://hook.io/'
    it { expect { subject.run }.not_to raise_error }
  end
end

