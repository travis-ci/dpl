require 'cl'
require 'logger'
require 'open3'
require 'rendezvous'
require 'tmpdir'

module Dpl
  module Ctx
    class Bash < Cl::Ctx
      attr_accessor :folds, :stdout, :stderr

      def initialize(stdout = $stdout, stderr = $stderr)
        @stdout, @stderr = stdout, stderr
        @folds = 0
        super('dpl')
      end

      # output

      def fold(msg)
        self.folds += 1
        print "travis_fold:start:dpl.#{folds}\r"
        info "\e[33m#{msg}\e[0m"
        yield
      ensure
        print "\ntravis_fold:end:dpl.#{folds}\r"
      end

      def deprecate_opt(key, msg)
        msg = "please use #{msg}" if msg.is_a?(Symbol)
        warn "Deprecated option #{key} used (#{msg})."
      end

      def info(*msgs)
        stdout.puts(*msgs)
      end

      def print(chars)
        stdout.print(chars)
      end

      def warn(*msgs)
        msgs = msgs.join("\n").lines
        msgs.each { |msg| stderr.puts("\e[31;1m#{msg}\e[0m") }
      end

      def error(message)
        raise Error, message
      end

      def logger(level = :info)
        logger = Logger.new(stderr)
        logger.level = Logger.const_get(level.to_s.upcase)
        logger
      end

      # shell commands

      def apt_get(name, cmd)
        shell "sudo apt-get -qq install #{name}", retry: true unless which(cmd)
      end

      def npm_install(name, cmd = name)
        shell "npm install -g #{name}", retry: true unless which(cmd)
      end

      def pip_install(name, cmd = name, version = nil)
        shell "pip uninstall --user -y #{name}" if version && which(cmd) # why only if version was given?
        cmd = "pip install --user #{name}"
        cmd << "==#{version}" if version
        shell cmd, echo: true, retry: true
        shell 'export PATH=$PATH:$HOME/.local/bin' # i don't think this propagates to the parent process
      end

      def ssh_keygen(name, file)
        shell %(ssh-keygen -t rsa -N "" -C #{name} -f #{file})
      end

      # TODO add retry
      def shell(cmd, opts = {})
        cmd = "#{cmd} > /dev/null 2>&1" if opts[:silence]
        cmd = with_python(cmd, opts[:python]) if opts[:python]

        info cmd if opts[:echo]
        out, err, @last_status = opts[:capture] ? open3(cmd, opts) : system(cmd, opts)

        info opts[:info] % { out: out } if opts[:info] && success?
        error opts[:assert] % { err: err } if opts[:assert] && !success?

        @last_status
      end

      def open3(cmd, opts)
        opts = [opts[:chdir] ? only(opts, :chdir) : nil].compact
        Open3.capture3(cmd, *opts)
      end

      def system(cmd, opts)
        opts = [opts[:chdir] ? only(opts, :chdir) : nil].compact
        [Kernel.system(cmd, *opts), '', last_process_status]
      end

      # $? is a read-only variable, so we use a method that we can stub during tests.
      def last_process_status
        $?.success?
      end

      def with_python(cmd, version)
        "bash -c 'source $HOME/virtualenv/python#{version}/bin/activate; #{cmd.gsub(/'/, "'\\\\''")}'"
      end

      def success?
        !!@last_status
      end

      # system and filesystem info

      def repo_name
        ENV['TRAVIS_REPO_SLUG'] ? ENV['TRAVIS_REPO_SLUG'].split('/').last : File.basename(Dir.pwd)
      end

      def repo_slug
        ENV['TRAVIS_REPO_SLUG'] || Dir.pwd.split('/')[-2, 2].join('/')
      end

      def build_dir
        ENV['TRAVIS_BUILD_DIR'] || '.'
      end

      def build_number
        ENV['TRAVIS_BUILD_NUMBER'] || raise('TRAVIS_BUILD_NUMBER not set')
      end

      def encoding(path)
        case `file '#{path}'`
        when /gzip compressed/
          'gzip'
        when /compress'd/
          'compress'
        when /text/
          'text'
        when /data/
          # shrugs?
        end
      end

      def git_commit_msg
        `git log #{git_sha} -n 1 --pretty=%B`.chomp
      end

      def git_log(args)
        `git log #{args}`.chomp
      end

      def git_ls_files
        `git ls-files -z`.split("\x0")
      end

      def git_remote_urls
        `git remote -v`.scan(/\t[^\s]+\s/).map(&:strip).uniq
      end

      def git_rev_parse(ref)
        `git rev-parse #{ref}`.strip
      end

      def git_tag
        `git describe --tags --exact-match 2>/dev/null`.chomp
      end

      def git_sha
        ENV['TRAVIS_COMMIT'] || `git rev-parse HEAD`.chomp
      end

      def machine_name
        `hostname`.strip
      end

      def npm_version
        `npm --version`
      end

      def which(cmd)
        !`which #{cmd}`.chomp.empty?
      end

      def tmp_dir
        Dir.mktmpdir
      end

      # external

      def rendezvous(url)
        Rendezvous.start(url: url)
      end

      def only(hash, *keys)
        hash.select { |key, _| keys.include?(key) }.to_h
      end

      def test?
        false
      end
    end
  end
end
