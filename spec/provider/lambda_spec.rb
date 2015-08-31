require 'spec_helper'
require 'aws-sdk'
require 'dpl/error'
require 'dpl/provider'
require 'dpl/provider/lambda'

describe DPL::Provider::Lambda do

  subject :provider do
    described_class.new(DummyContext.new, :access_key_id => 'qwertyuiopasdfghjklz', :secret_access_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz')
  end

  describe '#lambda_options' do
    context 'without region' do
      example do
        options = provider.lambda_options
        expect(options[:region]).to eq('us-east-1')
      end
    end

    context 'with region' do
      example do
        region = 'us-west-1'
        provider.options.update(:region => region)
        options = provider.lambda_options
        expect(options[:region]).to eq(region)
      end
    end
  end
end

describe DPL::Provider::Lambda do
  access_key_id = 'someaccesskey'
  secret_access_key = 'somesecretaccesskey'
  region = 'us-east-1'

  client_options = {
    stub_responses: true,
    region: region,
    credentials: Aws::Credentials.new(access_key_id, secret_access_key)
  }

  subject :provider do
    described_class.new(DummyContext.new, {
      access_key_id: access_key_id,
      secret_access_key: secret_access_key
    })
  end

  before :each do
    provider.stub(:lambda_options).and_return(client_options)
  end

  describe '#lambda' do
    example do
      expect(Aws::LambdaPreview::Client).to receive(:new).with(client_options).once
      provider.lambda
    end
  end

  describe '#push_app' do
    lambda_options = {
      function_name: 'test-function',
      role: 'some-role',
      module_name: 'index',
      handler_name: 'handler'
    }

    example_response = {
      function_name: 'test-function',
      role: 'some-role',
      handler: 'index.handler'
    }

    before(:each) do
      old_options = provider.options
      provider.stub(:options) { old_options.merge(lambda_options) }
    end

    context 'with a successful response' do
      before do
        provider.lambda.stub_responses(:upload_function, example_response)
      end

      example do
        expect(provider).to receive(:log).with(/Uploaded lambda: #{lambda_options[:function_name]}\./)
        provider.push_app
      end
    end

    context 'with a ServiceException response' do
      before do
        provider.lambda.stub_responses(:upload_function, 'ServiceException')
      end

      example do
        expect(provider).to receive(:error).once
        provider.push_app
      end
    end

    context 'with a InvalidParameterValueException response' do
      before do
        provider.lambda.stub_responses(:upload_function, 'InvalidParameterValueException')
      end

      example do
        expect(provider).to receive(:error).once
        provider.push_app
      end
    end

    context 'with a ResourceNotFoundException response' do
      before do
        provider.lambda.stub_responses(:upload_function, 'ResourceNotFoundException')
      end

      example do
        expect(provider).to receive(:error).once
        provider.push_app
      end
    end
  end

  describe "#handler" do
    context "without a module name" do
      module_name = 'index'
      handler_name = 'HandlerName'
      expected_handler = "#{module_name}.#{handler_name}"

      before do
        expect(provider.options).to receive(:[]).with(:module_name).and_return(nil)
        expect(provider.options).to receive(:fetch).with(:handler_name).and_return(handler_name)
      end

      example do
        expect(provider.handler).to eq(expected_handler)
      end
    end

    context "with a module name" do
      module_name = 'ModuleName'
      handler_name = 'HandlerName'
      expected_handler = "#{module_name}.#{handler_name}"

      before do
        expect(provider.options).to receive(:[]).with(:module_name).and_return(module_name)
        expect(provider.options).to receive(:fetch).with(:handler_name).and_return(handler_name)
      end

      example do
        expect(provider.handler).to eq(expected_handler)
      end
    end
  end

  describe '#function_zip' do
    context 'when zip is not specified' do
      path = Dir.pwd
      output_file_path = '/some/path.zip'

      before do
        expect(provider.options).to receive(:[]).with(:zip).and_return(nil)
        expect(provider).to receive(:output_file_path).and_return(output_file_path)
        expect(File).to receive(:directory?).with(path).and_return(true)
        expect(provider).to receive(:zip_directory).with(output_file_path, path)
        expect(File).to receive(:new).with(output_file_path)
      end

      example do
        provider.function_zip
      end
    end

    context 'when zip is a file path' do
      path = '/some/file/path.zip'
      output_file_path = '/some/path.zip'

      before do
        expect(provider.options).to receive(:[]).with(:zip).and_return(path)
        expect(provider).to receive(:output_file_path).and_return(output_file_path)
        expect(File).to receive(:directory?).with(path).and_return(false)
        expect(File).to receive(:file?).with(path).and_return(true)
        expect(provider).to receive(:zip_file).with(output_file_path, path)
        expect(File).to receive(:new).with(output_file_path)
      end

      example do
        provider.function_zip
      end
    end

    context 'when zip is a directory' do
      path = '/some/dir/path'
      output_file_path = '/some/path.zip'

      before do
        expect(provider.options).to receive(:[]).with(:zip).and_return(path)
        expect(provider).to receive(:output_file_path).and_return(output_file_path)
        expect(File).to receive(:directory?).with(path).and_return(true)
        expect(provider).to receive(:zip_directory).with(output_file_path, path)
        expect(File).to receive(:new).with(output_file_path)
      end

      example do
        provider.function_zip
      end
    end

    context 'with an invalid zip option' do
      path = '/some/file/path.zip'
      output_file_path = '/some/path.zip'
      error = 'Invalid zip option. If set, must be path to directory, js file, or a zip file.'

      before do
        expect(provider.options).to receive(:[]).with(:zip).and_return(path)
        expect(provider).to receive(:output_file_path).and_return(output_file_path)
        expect(File).to receive(:directory?).with(path).and_return(false)
        expect(File).to receive(:file?).with(path).and_return(false)
      end

      example do
        expect { provider.function_zip }.to raise_error(DPL::Error, error)
      end
    end
  end

  describe '#zip_file' do
    dest = '/some/path/to/write.zip'

    context 'when zip is a file path' do
      dir = '/some/target'
      target = File.join(dir, 'file.js')

      before do
        expect(File).to receive(:extname).with(target).and_return('.js')
        expect(provider).to receive(:create_zip).with(dest, dir, [ target ])
      end

      example do
        provider.zip_file(dest, target)
      end
    end

    context 'when zip is an existing zip file' do
      dir = '/some/target'
      target = File.join(dir, 'file.js')

      before do
        expect(File).to receive(:extname).with(target).and_return('.zip')
        expect(FileUtils).to receive(:cp).with(target, dest)
      end

      example do
        provider.zip_file(dest, target)
      end
    end
  end

  describe '#zip_directory' do
    dest = '/some/path/to/write.zip'
    target = '/some/dir'
    glob = File.join(target, '**', '**')
    files = %w[ 'one' 'two' ]

    before do
      expect(Dir).to receive(:[]).with(glob).and_return(files)
      expect(provider).to receive(:create_zip).with(dest, target, files)
    end

    example do
      provider.zip_directory(dest, target)
    end
  end

  describe '#create_zip' do
    dest = '/some/dest.zip'
    src = '/some/src/dir'
    file_one = 'one.js'
    file_two = 'two.js'
    files = [
      File.join(src, file_one),
      File.join(src, file_two)
    ]

    before do
      zip_file = double(Zip::File)
      expect(Zip::File).to receive(:open).with(dest, Zip::File::CREATE).and_yield(zip_file)
      expect(zip_file).to receive(:add).once.with(file_one, File.join(src, file_one))
      expect(zip_file).to receive(:add).once.with(file_two, File.join(src, file_two))
    end

    example do
      provider.create_zip(dest, src, files)
    end
  end

  describe '#needs_key?' do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe '#check_auth' do
    example do
      expect(provider).to receive(:log).with("Using Access Key: #{access_key_id[-4..-1].rjust(20, '*')}")
      provider.check_auth
    end
  end

  describe '#output_file_path' do
    example do
      expect(provider.output_file_path).to match(/tmp\/\w{8}\-lambda\.zip/)
    end
  end

  describe '#default_runtime' do
    example do
      expect(provider.default_runtime).to eq('nodejs')
    end
  end

  describe '#default_mode' do
    example do
      expect(provider.default_mode).to eq('event')
    end
  end

  describe '#default_timeout' do
    example do
      expect(provider.default_timeout).to eq(3)
    end
  end

  describe '#default_description' do
    build_number = 2

    before do
      provider.context.env.stub(:[]).with('TRAVIS_BUILD_NUMBER').and_return(build_number)
    end

    let(:build_number) { provider.context.env['TRAVIS_BUILD_NUMBER'] }

    example do
      expect(provider.default_description).to eq(
        "Deploy build #{build_number} to AWS Lambda via Travis CI"
      )
    end
  end

  describe '#deafult_memory_size' do
    example do
      expect(provider.deafult_memory_size).to eq(128)
    end
  end

  describe '#random_chars' do
    context 'without specifying count' do
      example do
        expect(provider.random_chars.length).to eq(8)
      end
    end

    context 'with specified count' do
      count = 4
      example do
        expect(provider.random_chars(count).length).to eq(count)
      end
    end
  end

end
