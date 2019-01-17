require 'spec_helper'
require 'dpl/provider/vsce'

describe DPL::Provider::VSCE do
  context 'when token is not provided' do
    subject :provider do
      described_class.new(DummyContext.new, {})
    end

    describe '#check_auth' do
      example do
        expect { provider.check_auth }.to raise_error(DPL::Error, 'missing token')
      end
    end
  end

  context 'when token is provided' do
    subject :provider do
      described_class.new(DummyContext.new, token: 'TEST_TOKEN')
    end

    describe '#check_auth' do
      example do
        expect { provider.check_auth }.not_to raise_error
      end
    end

    context 'when publish fails' do
      before { expect(File).to receive(:read).with('package.json').and_return('{"name":"helloworld-minimal-sample","description":"Minimal HelloWorld example for VS Code","version":"0.0.1","publisher":"travis-tests","repository":"https://github.com/Microsoft/vscode-extension-samples/helloworld-minimal-sample","engines":{"vscode":"^1.25.0"},"activationEvents":["onCommand:extension.helloWorld"],"main":"./extension.js","contributes":{"commands":[{"command":"extension.helloWorld","title":"Hello World"}]},"scripts":{"postinstall":"node ./node_modules/vscode/bin/install"},"devDependencies":{"vscode":"^1.1.22"}}') }
      describe '#push_app' do
        example do
          expect(provider.context).to receive(:shell).with('vsce package')
          expect(provider.context).to receive(:shell).with('vsce publish --pat TEST_TOKEN') { false }
          expect { provider.push_app }.to raise_error('Publish failed')
        end
      end
    end

    context 'when publish succeeds' do
      # Files taken from the minimal sample: https://github.com/Microsoft/vscode-extension-samples/blob/master/helloworld-minimal-sample/
      before { expect(File).to receive(:read).with('package.json').and_return('{"name":"helloworld-minimal-sample","description":"Minimal HelloWorld example for VS Code","version":"0.0.1","publisher":"travis-tests","repository":"https://github.com/Microsoft/vscode-extension-samples/helloworld-minimal-sample","engines":{"vscode":"^1.25.0"},"activationEvents":["onCommand:extension.helloWorld"],"main":"./extension.js","contributes":{"commands":[{"command":"extension.helloWorld","title":"Hello World"}]},"scripts":{"postinstall":"node ./node_modules/vscode/bin/install"},"devDependencies":{"vscode":"^1.1.22"}}') }
      describe '#push_app' do
        example do
          expect(provider.context).to receive(:shell).with('vsce package')
          expect(provider.context).to receive(:shell).with('vsce publish --pat TEST_TOKEN') { true }
          provider.push_app
        end
      end
    end
  end
end
