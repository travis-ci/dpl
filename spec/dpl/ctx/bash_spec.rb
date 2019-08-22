require 'stringio'

describe Dpl::Ctx::Bash do
  let(:provider) { Class.new(Dpl::Provider).new(ctx, []) }
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }
  let(:status) { true }
  let(:captures) { ['stdout', '', true] }

  subject { described_class.new(stdout, stderr) }

  before { allow(subject).to receive(:`).and_return('') }
  before { allow(Kernel).to receive(:system).and_return status }
  before { allow(Open3).to receive(:capture3).and_return(captures) }
  before { allow_any_instance_of(described_class).to receive(:last_process_status).and_return(status) }

  def self.cmds(cmds)
    before { cmds.each { |cmd, str| allow(subject).to receive(:`).with(cmd.to_s).and_return(str) } }
  end

  chdir 'tmp/dpl'

  matcher :have_stdout do |str|
    match do
      matcher = str.is_a?(Regexp) ? :match : :include
      expect(stdout.string).to send(matcher, str)
    end

    failure_message do
      "Expected stdout to include\n\n  #{str}\n\nbut it does not. Instead stdout is:\n\n  #{stdout.string}"
    end
  end

  matcher :have_stderr do |str|
    match do
      expect(stderr.string).to match(str)
    end

    failure_message do
      "Expected stderr to include\n\n  #{str}\n\nbut it does not. Instead stderr is:\n\n  #{stderr.string}"
    end
  end

  matcher :call_system do |cmd, opts = {}|
    match do |obj|
      opts = [opts.any? ? opts : nil].compact
      matcher = have_received(:system)
      matcher = matcher.with(cmd, *opts) if cmd
      expect(Kernel).to matcher
    end

    failure_message do
      args = RSpec::Mocks.space.proxy_for(Kernel).messages_arg_list # hmmm.
      "Expected system to be called with\n\n  #{cmd}\n\nbut it was not. Instead it was called with:\n\n  #{args.join("\n")}"
    end
  end

  matcher :call_capture3 do |cmd, opts = {}|
    match do |obj|
      opts = [opts.any? ? opts : nil].compact
      matcher = have_received(:capture3)
      matcher = matcher.with(cmd, *opts) if cmd
      expect(Open3).to matcher
    end

    failure_message do
      args = RSpec::Mocks.space.proxy_for(Open3).messages_arg_list # hmmm.
      "Expected Open3.capture3 to be called with\n\n  #{cmd}\n\nbut it was not. Instead it was called with:\n\n  #{args.join("\n")}"
    end
  end

  # output

  describe 'fold' do
    before { subject.fold('foo') { stdout.puts 'bar' } }
    it { should have_stdout "travis_fold:start:dpl.1\r\e[K" }
    it { should have_stdout "\e[33mfoo\e[0m\nbar\n" }
    it { should have_stdout "\ntravis_fold:end:dpl.1\r\e[K" }
  end

  describe 'deprecated_opt' do
    describe 'given a symbol' do
      before { subject.deprecate_opt(:old, :new) }
      it { should have_stderr /Deprecated option old used \(please use new\)/ }
    end

    describe 'given a string' do
      before { subject.deprecate_opt(:old, 'has no effect') }
      it { should have_stderr /Deprecated option old used \(has no effect\)/ }
    end
  end

  describe 'info' do
    before { subject.info('str') }
    it { should have_stdout "str\n" }
  end

  describe 'print' do
    before { subject.print('str') }
    it { should have_stdout /str(?!\n)/ }
  end

  describe 'warn' do
    before { subject.warn('str') }
    it { should have_stderr "\e[33;1mstr\e[0m\n" }
  end

  describe 'error' do
    it { expect { subject.error('str') }.to raise_error Dpl::Error, 'str' }
  end

  describe 'logger' do
    let(:logger) { subject.logger(:debug) }
    it { expect(logger).to be_a Logger }
    it { expect(logger.level).to eq Logger::DEBUG }
  end

  # shell commands

  describe 'validate_runtimes' do
    describe 'node_js' do
      let(:runtimes) { [[:node_js, ['>= 11.0.0']]] }
      before { allow(subject).to receive(:`).with('node -v').and_return(version) }

      describe 'satisfied' do
        let(:version) { 'v11.0.0' }
        it { expect { subject.validate_runtimes(runtimes) }.to_not raise_error }
      end

      describe 'fails' do
        let(:version) { 'v10.0.0' }
        it { expect { subject.validate_runtimes(runtimes) }.to raise_error 'Failed validating runtimes: node_js (>= 11.0.0)' }
      end
    end

    describe 'python' do
      let(:runtimes) { [[:python, ['>= 2.7', '!= 3.0', '!= 3.1', '!= 3.2', '!= 3.3', '< 3.8']]] }
      before { allow(subject).to receive(:`).with('python --version 2>&1').and_return(version) }

      describe 'satisfied (2.7)' do
        let(:version) { 'Python 2.7.9' }
        it { expect { subject.validate_runtimes(runtimes) }.to_not raise_error }
      end

      describe 'satisfied (2.7)' do
        let(:version) { 'Python 2.7.9' }
        it { expect { subject.validate_runtimes([[:python, ['= 2.7']]]) }.to_not raise_error }
      end

      describe 'satisfied (2.7.13)' do
        let(:version) { 'Python 2.7.13' }
        it { expect { subject.validate_runtimes([[:python, ['>= 2.7.9']]]) }.to_not raise_error }
      end

      describe 'satisfied (3.6)' do
        let(:version) { 'Python 3.6' }
        it { expect { subject.validate_runtimes(runtimes) }.to_not raise_error }
      end

      describe 'fails' do
        let(:version) { '3.0.1' }
        it { expect { subject.validate_runtimes(runtimes) }.to raise_error 'Failed validating runtimes: python (>= 2.7, != 3.0, != 3.1, != 3.2, != 3.3, < 3.8)' }
      end
    end
  end

  describe 'apts_get' do
    before { allow(subject).to receive(:`).with('which cmd').and_return('/bin/cmd') }
    before { allow(subject).to receive(:`).with('which two').and_return('') }
    before { subject.apts_get([['one', 'cmd'], ['two']]) }

    it { should_not call_system }
    it { should call_system 'sudo apt-get update' }
    it { should_not call_system 'sudo apt-get -qq install one' }
    it { should call_system 'sudo apt-get -qq install two' }
  end

  describe 'apt_get' do
    describe 'cmd exists' do
      before { allow(subject).to receive(:`).with('which cmd').and_return('/bin/cmd') }
      before { subject.apt_get('name', 'cmd') }
      it { should_not call_system }
    end

    describe 'cmd does not exist' do
      before { subject.apt_get('name', 'cmd') }
      it { should call_system 'sudo apt-get update' }
      it { should call_system 'sudo apt-get -qq install name' }
    end
  end

  describe 'npm_install' do
    describe 'cmd exists' do
      before { allow(subject).to receive(:`).with('which cmd').and_return('/bin/cmd') }
      before { subject.npm_install('name', 'cmd') }
      it { should_not call_system }
    end

    describe 'cmd does not exist' do
      before { subject.npm_install('name', 'cmd') }
      it { should call_system 'npm install -g name' }
    end
  end

  describe 'pip_install' do
    describe 'version req given' do
      before { subject.pip_install('name', 'cmd', '1.0.0') }
      it { should call_system 'virtualenv --no-site-packages ~/dpl_venv' }
      it { should call_system 'pip install name==1.0.0' }
    end

    describe 'no version req given' do
      before { subject.pip_install('name', 'cmd') }
      it { should call_system 'virtualenv --no-site-packages ~/dpl_venv' }
      it { should call_system 'pip install name' }
    end
  end

  describe 'shell' do
    describe 'echo' do
      let!(:result) { subject.shell('echo one', echo: true) }
      it { expect(result).to be true }
      it { should have_stdout "echo one\n" }
      it { should call_system 'echo one' }
    end

    describe 'silence' do
      let!(:result) { subject.shell('echo one', silence: true) }
      it { expect(result).to be true }
      it { should call_system 'echo one > /dev/null 2>&1' }
    end

    describe 'python' do
      let!(:result) { subject.shell('echo one', python: '2.7') }
      it { expect(result).to be true }
      it { should call_system 'source $HOME/virtualenv/python2.7/bin/activate && echo one' }
    end

    describe 'success' do
      let(:status) { true }
      let!(:result) { subject.shell('echo one', success: 'success') }
      it { expect(result).to be true }
      it { should call_system 'echo one' }
      it { should have_stdout 'success' }
    end

    describe 'assert' do
      let(:status) { false }
      let(:result) { subject.shell('echo one', assert: 'failed') }
      it { expect { result }.to raise_error Dpl::Error, 'failed' }
    end

    describe 'capture' do
      let(:captures) { ['stdout', '', double(success?: true)] }
      let!(:result) { subject.shell('echo one', capture: true) }
      it { expect(result).to eq 'stdout' }
      it { should call_capture3 'echo one' }
    end

    describe 'capture (info)' do
      let(:captures) { ['stdout', '', double(success?: true)] }
      let!(:result) { subject.shell('echo one', capture: true, success: 'stdout: %{out}') }
      it { expect(result).to eq 'stdout' }
      it { should call_capture3 'echo one' }
      it { should have_stdout 'stdout: stdout' }
    end

    describe 'capture (assert)' do
      let(:captures) { ['', 'stderr', double(success?: false)] }
      let(:result) { subject.shell('echo one', capture: true, assert: 'stderr: %{err}') }
      it { expect { result }.to raise_error Dpl::Error, 'stderr: stderr' }
    end
  end

  # system and filesystem info

  describe 'repo_name' do
    describe 'TRAVIS_REPO_SLUG set' do
      env TRAVIS_REPO_SLUG: 'travis-ci/dpl'
      it { expect(subject.repo_name).to eq 'dpl' }
    end

    describe 'TRAVIS_REPO_SLUG not set' do
      it { expect(subject.repo_name).to eq 'dpl' }
    end
  end

  describe 'repo_slug' do
    describe 'TRAVIS_REPO_SLUG set' do
      env TRAVIS_REPO_SLUG: 'travis-ci/dpl'
      it { expect(subject.repo_slug).to eq 'travis-ci/dpl' }
    end

    describe 'TRAVIS_REPO_SLUG not set' do
      it { expect(subject.repo_slug).to eq 'tmp/dpl' }
    end
  end

  describe 'repo_slug' do
    describe 'TRAVIS_BUILD_DIR set' do
      env TRAVIS_BUILD_DIR: '/build/travis-ci/dpl'
      it { expect(subject.build_dir).to eq '/build/travis-ci/dpl' }
    end

    describe 'TRAVIS_BUILD_DIR not set' do
      it { expect(subject.build_dir).to eq '.' }
    end
  end

  describe 'build_number' do
    describe 'TRAVIS_BUILD_NUMBER set' do
      env TRAVIS_BUILD_NUMBER: 1
      it { expect(subject.build_number).to eq '1' }
    end

    describe 'TRAVIS_BUILD_NUMBER not set' do
      it { expect { subject.build_number }.to raise_error 'TRAVIS_BUILD_NUMBER not set' }
    end
  end

  describe 'encoding' do
    describe 'gziped' do
      cmds "file 'one'": 'one: gzip compressed data, last modified: Wed May 15 12:00:00 2019, from Unix, original size 4'
      it { expect(subject.encoding('one')).to eq 'gzip' }
    end

    describe 'compressed' do
      cmds "file 'one'": "one: compress'd data 16 bits"
      it { expect(subject.encoding('one')).to eq 'compress' }
    end

    describe 'text' do
      cmds "file 'one'": "one: ASCII text"
      it { expect(subject.encoding('one')).to eq 'text' }
    end
  end

  describe 'git_commit_msg' do
    before { allow(subject).to receive(:git_sha).and_return('1234') }
    cmds 'git log 1234 -n 1 --pretty=%B': "commit msg\n"
    it { expect(subject.git_commit_msg).to eq 'commit msg' }
  end

  describe 'git_author_name' do
    before { allow(subject).to receive(:git_sha).and_return('1234') }
    cmds 'git log 1234 -n 1 --pretty=%an': "author name\n"
    it { expect(subject.git_author_name).to eq 'author name' }
  end

  describe 'git_author_email' do
    before { allow(subject).to receive(:git_sha).and_return('1234') }
    cmds 'git log 1234 -n 1 --pretty=%ae': "author email\n"
    it { expect(subject.git_author_email).to eq 'author email' }
  end

  describe 'git_log' do
    cmds 'git log -n 1 --oneline': "1234 commit msg\n"
    it { expect(subject.git_log('-n 1 --oneline')).to eq '1234 commit msg' }
  end

  describe 'git_ls_files' do
    cmds 'git ls-files -z': "one\x0two"
    it { expect(subject.git_ls_files).to eq ['one', 'two'] }
  end

  describe 'git_remote_urls' do
    cmds 'git remote -v': sq(<<-out)
      one\tgit://one.git (fetch)
      one\tgit://one.git (push)
      two\tgit://two.git (fetch)
      two\tgit://two.git (push)
    out
    it { expect(subject.git_remote_urls).to eq ['git://one.git', 'git://two.git'] }
  end

  describe 'git_rev_parse' do
    cmds 'git rev-parse HEAD': '1234'
    it { expect(subject.git_rev_parse('HEAD')).to eq '1234' }
  end

  describe 'git_tag' do
    cmds 'git describe --tags --exact-match 2>/dev/null': 'v1.0.0'
    it { expect(subject.git_tag).to eq 'v1.0.0' }
  end

  describe 'git_sha' do
    describe 'TRAVIS_COMMIT set' do
      env TRAVIS_COMMIT: '1234'
      it { expect(subject.git_sha).to eq '1234' }
    end

    describe 'TRAVIS_COMMIT not set' do
      cmds 'git rev-parse HEAD': '1234'
      it { expect(subject.git_sha).to eq '1234' }
    end
  end

  describe 'machine_name' do
    cmds 'hostname': 'machine hostname'
    it { expect(subject.machine_name).to eq 'machine hostname' }
  end

  describe 'npm_version' do
    cmds 'npm --version': '6.5.0'
    it { expect(subject.npm_version).to eq '6.5.0' }
  end

  describe 'which' do
    describe 'cmd exists' do
      cmds 'which cmd': '/bin/cmd'
      it { expect(subject.which('cmd')).to be true }
    end

    describe 'cmd does not exist' do
      it { expect(subject.which('cmd')).to be false }
    end
  end

  describe 'tmp_dir' do
    it { expect(subject.tmp_dir).to match %r(/(tmp|var)/) }
  end
end
