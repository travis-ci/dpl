describe Dpl::Providers::DataPipeline do
  include Support::Matchers::Aws

  let(:args)   { |e| %w(--name name --definition ./definition.json --access_key_id access_key_id --secret_access_key secret_access_key) + args_from_description(e) }
  let(:client) { Aws::DataPipeline::Client.new(stub_responses: responses) }
  let(:pipes)  { [{ id: '1' }] }

  let(:responses) do
    {
      list_pipelines: {
        pipeline_id_list: pipes
      },
      create_pipeline: {
        pipeline_id: '1'
      }
    }
  end

  env TRAVIS_BUILD_NUMBER: 1

  file 'definition.json', '{}'

  before { allow(Aws::DataPipeline::Client).to receive(:new).and_return(client) }
  before { |c| subject.run unless c.metadata[:run].is_a?(FalseClass) }

  describe 'login' do
    it { should have_run '[info] Using Access Key: ac******************' }
  end

  describe 'no pipeline exists' do
    let(:pipes) { [] }
    it { should create_pipeline name: 'name', uniqueId: 'name', tags: [] }
    it { should update_pipeline pipelineId: '1', pipelineObjects: [], parameterObjects: [] }
  end

  describe 'pipelines exist' do
    let(:pipes) { [{ id: '1', name: 'name' }, { id: '2', name: 'name' }] }
    it { should delete_pipeline pipelineId: '1' }
    it { should delete_pipeline pipelineId: '2' }
    it { should create_pipeline name: 'name', uniqueId: 'name', tags: [] }
    it { should update_pipeline pipelineId: '1', pipelineObjects: [], parameterObjects: [] }
  end

  describe 'with ~/.aws/credentials', run: false do
    let(:args) { |e| %w(--name name --definition ./definition.json) }

    file '~/.aws/credentials', <<-str.sub(/^\s*/, '')
      [default]
      aws_access_key_id=access_key_id
      aws_secret_access_key=secret_access_key
    str

    before { subject.run }
    it { should have_run '[info] Using Access Key: ac******************' }
  end
end

describe Dpl::Providers::DataPipeline::Definition do
  let(:defn) { described_class.new(stringify(data)) }

  describe 'objects' do
    subject { defn.objects }

    describe 'string value' do
      let(:data) { { objects: [{ id: 'id', name: 'name', type: 'type' }] } }
      it { should eq [id: 'id', name: 'name', fields: [key: 'type', string_value: 'type']] }
    end

    describe 'ref value' do
      let(:data) { { objects: [{ id: 'id', name: 'name', foo: { ref: 'ref' } }] } }
      it { should eq [id: 'id', name: 'name', fields: [key: 'foo', ref_value: 'ref']] }
    end
  end

  describe 'params' do
    subject { defn.params }
    let(:data) { { parameters: [{ id: 'id', type: 'type' }] } }
    it { should eq [id: 'id', attributes: [key: 'type', string_value: 'type']] }
  end

  describe 'values' do
    subject { defn.values }
    let(:data) { { values: { key: 'value' } } }
    it { should eq [id: 'key', string_value: 'value'] }
  end
end
