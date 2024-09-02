# frozen_string_literal: true

require 'English'
require 'cl'
require 'fileutils'
require 'logger'
require 'open3'
require 'tmpdir'
require 'securerandom'
require 'dpl/support/version'

module Dpl
  module Ctx
    class Bash < Cl::Ctx
      include FileUtils

      attr_accessor :folds, :stdout, :stderr, :last_out, :last_err

      def initialize(stdout = $stdout, stderr = $stderr)
        @stdout = stdout
        @stderr = stderr
        @folds = 0
        super('dpl', abort: false)
      end

      # Folds any log output from the given block
      #
      # Starts a log fold with the given fold message, calls the block, and
      # closes the fold.
      #
      # @param msg [String] the message that will appear on the log fold
      def fold(msg)
        self.folds += 1
        print "travis_fold:start:dpl.#{folds}\r\e[K"
        time do
          info "\e[33m#{msg}\e[0m"
          yield
        end
      ensure
        print "\ntravis_fold:end:dpl.#{folds}\r\e[K"
      end

      # Times the given block
      #
      # Starts a travis time log tag, calls the block, and closes the tag,
      # including timing information. This makes a timing badge appear on
      # the surrounding log fold.
      def time
        id = SecureRandom.hex[0, 8]
        start = Time.now.to_i * (10**9)
        print "travis_time:start:#{id}\r\e[K"
        yield
      ensure
        finish = Time.now.to_i * (10**9)
        duration = finish - start
        print "\ntravis_time:end:#{id}:start=#{start},finish=#{finish},duration=#{duration}\r\e[K"
      end

      # Outputs a deprecation warning for a given deprecated option key to stderr.
      #
      # @param key [Symbol] the deprecated option key
      # @param msg [String or Symbol] the deprecation message. if given a Symbol this will be wrapped into the string "Please use #{symbol}".
      def deprecate_opt(key, msg)
        msg = "please use #{msg}" if msg.is_a?(Symbol)
        warn "Deprecated option #{key} used (#{msg})."
      end

      # Outputs an info level message to stdout.
      def info(*msgs)
        stdout.puts(*msgs)
      end

      # Prints an info level message to stdout.
      #
      # This method does not append a newline character to the given message,
      # which usually is not the desired behaviour. The method is intended to
      # be used if an initial, partial message is supposed to be printed, which
      # will be completed later (using the method `info`).
      #
      # For example:
      #
      #   print 'Starting a long running task ...'
      #   run_long_running_task
      #   info 'done.'
      def print(chars)
        stdout.print(chars)
      end

      # Outputs an warning message to stderr
      #
      # This method is intended to be used for warning messages that are
      # supposed to show up in the build log, but do not qualify as errors that
      # would abort the deployment process. The warning will be highlighted as
      # yellow text. Use sparingly.
      def warn(*msgs)
        msgs = msgs.join("\n").lines
        msgs.each { |msg| stderr.puts("\e[33;1m#{msg}\e[0m") }
      end

      # Raises an exception, halting the deployment process.
      #
      # The calling executable `bin/dpl` will catch the exception, and abort
      # the ruby process with the given error message.
      #
      # This method is intended to be used for all error conditions that
      # require the deployment process to be aborted.
      def error(message)
        raise Error, message
      end

      # Returns a logger
      #
      # Returns a logger instance, with the given log level set. This can be
      # used to pass to clients that accept a Ruby logger, such as Faraday,
      # for debugging purposes.
      #
      # Use with care.
      #
      # @param level [Symbol] the Ruby logger log level
      def logger(level = :info)
        logger = Logger.new(stderr)
        logger.level = Logger.const_get(level.to_s.upcase)
        logger
      end

      def validate_runtimes(runtimes)
        failed = runtimes.reject(&method(:validate_runtime))
        failed = failed.map { |name, versions| "#{name} (#{versions.join(', ')})" }
        error "Failed validating runtimes: #{failed.join(', ')}" if failed.any?
      end

      def validate_runtime(args)
        name, required = *args
        info "Validating required runtime version: #{name} (#{required.join(', ')})"
        version = name == :node_js ? node_version : python_version
        required.all? { |required| Version.new(version).satisfies?(required) }
      end

      def apts_get(packages)
        packages = packages.reject { |name, cmd = name| which(cmd || name) }
        return unless packages.any?

        apt_update
        packages.each { |package, cmd| apt_get(package, cmd || package, update: false) }
      end

      # Installs an APT package
      #
      # Installs the APT package with the given name, unless the command is already
      # available (as determined by `which [cmd]`.
      #
      # @param package [String] the package name
      # @param cmd [String] an executable installed by the package, defaults to the package name
      def apt_get(package, cmd = package, opts = {})
        return if which(cmd)

        apt_update unless opts[:update].is_a?(FalseClass)
        shell "sudo apt-get -qq install #{package}", retry: true
      end

      def apt_update
        shell 'sudo apt-get update', retry: true
      end

      # Requires source files from Ruby gems, installing them on demand if required
      #
      # Installs the Ruby gems with the given version, if not already installed, and
      # requires the specified source files from that gem.
      #
      # This happens using the bundler/inline API.
      #
      # @param gems [Array<String, String, Hash>] Array of gem requirements: gem name, version, and options (`require`: A single path or a list of paths to source files to require from this Ruby gem)
      #
      # @see https://bundler.io/v2.0/guides/bundler_in_a_single_file_ruby_script.html
      def gems_require(gems)
        # A local Gemfile.lock might interfer with bundler/inline, even though
        # it should not. Switching to a temporary dir fixes this.
        Dir.chdir(tmp_dir) do
          require 'bundler/inline'
          info "Installing gem dependencies: #{gems.map { |name, version, _| "#{name} #{"(#{version})" if version}".strip }.join(', ')}"
          env = ENV.to_h
          # Bundler.reset!
          # Gem.loaded_specs.clear
          gemfile do
            source 'https://rubygems.org'
            gems.each do |g|
              gem(*g)
            end
          end
          # https://github.com/bundler/bundler/issues/7181
          ENV.replace(env)
        end
      end

      # Installs an NPM package
      #
      # Installs the NPM package with the given name, unless the command is already
      # available (as determined by `which [cmd]`.
      #
      # @param package [String] the package name
      # @param cmd [String] an executable installed by the package, defaults to the package name
      def npm_install(package, cmd = package)
        shell "npm install -g #{package}", retry: true unless which(cmd)
      end

      # Installs a Python package
      #
      # Installs the Python package with the given name. A previously installed
      # package is uninstalled before that, but only if `version` was given.
      #
      # @param package [String] Package name (required).
      # @param cmd     [String] Executable command installed by that package (optional, defaults to the package name).
      # @param version [String] Package version (optional).
      def pip_install(package, cmd = package, version = nil)
        ENV['VIRTUAL_ENV'] = File.expand_path('~/dpl_venv')
        ENV['PATH'] = File.expand_path("~/dpl_venv/bin:#{ENV['PATH']}")
        shell 'virtualenv ~/dpl_venv', echo: true
        shell 'pip install urllib3[secure]'
        cmd = "pip install #{package}"
        cmd << pip_version(version) if version
        shell cmd, retry: true
      end

      def pip_version(version)
        version =~ /^\d+/ ? "==#{version}" : version
      end

      # Generates an SSH key
      #
      # @param name [String] the key name
      # @param file [String] path to the key file
      def ssh_keygen(name, file)
        shell %(ssh-keygen -t rsa -N "" -C #{name} -f #{file})
      end

      # Runs a single shell command
      #
      # This the is the central point of executing any shell commands. It allows two
      # strategies for running commands in subprocesses:
      #
      # * Using [Kernel#system](https://ruby-doc.org/core-2.6.3/Kernel.html#method-i-system)
      #   which is the default strategy, and should be used when possible. The stdout
      #   and stderr streams will not be captured, but streamed directly to the parent
      #   process (so any output on these streams appears in the build log as soon as
      #   possible).
      #
      # * Using [Open3.capture3](https://ruby-doc.org/stdlib-2.6.3/libdoc/open3/rdoc/Open3.html#method-c-capture3)
      #   which captures both stdout and stderr, and does not automatically output it
      #   to the build log. Implementors can choose to display it after the shell command
      #   has completed, using the `%{out}` and `%{err}` interpolation variables. Use
      #   sparingly.
      #
      # The method accepts the following options:
      #
      # @param  cmd  [String] the shell command to execute
      # @param  opts [Hash] options
      #
      # @option opts [Boolean] :echo    output the command to stdout before running it
      # @option opts [Boolean] :silence silence all log output by redirecting stdout and stderr to `/dev/null`
      # @option opts [Boolean] :capture use `Open3.capture3` to capture stdout and stderr
      # @option opts [String]  :python  wrap the command into Bash code that enforces the given Python version to be used
      # @option opts [String]  :retry   retries the command 2 more times if it fails
      # @option opts [String]  :info    message to output to stdout if the command has exited with the exit code 0 (supports the interpolation variable `${out}` for stdout in case it was captured.
      # @option opts [String]  :assert  error message to be raised if the command has exited with a non-zero exit code (supports the interpolation variable `${out}` for stdout in case it was captured.
      #
      # @return [Boolean] whether or not the command was successful (has exited with the exit code 0)
      def shell(cmd, opts = {})
        cmd = Cmd.new(nil, cmd, opts) if cmd.is_a?(String)
        info cmd.msg if cmd.msg?
        info cmd.echo if cmd.echo?

        @last_out, @last_err, @last_status = retrying(cmd.retry ? 2 : 0) do
          send(cmd.capture? ? :open3 : :system, cmd.cmd, cmd.opts)
        end

        info format(cmd.success, out: last_out) if success? && cmd.success?
        error format(cmd.error, err: last_err) if failed? && cmd.assert?

        success? && cmd.capture? ? last_out.chomp : @last_status
      end

      def retrying(max, tries = 0, status = false)
        loop do
          tries += 1
          out, err, status = yield
          return [out, err, status] if status || tries > max
        end
      end

      # Runs a shell command and captures stdout, stderr, and the exit status
      #
      # Runs the given command using `Open3.capture3`, which will capture the
      # stdout and stderr streams, as well as the exit status. I.e. this will
      # *not* stream log output in real time, but capture the output, and allow
      # implementors to display it later (using the `%{out}` and `%{err}`
      # interpolation variables.
      #
      # Use sparingly.
      #
      # @option chdir [String] directory temporarily to change to before running the command
      def open3(cmd, opts)
        opts = [opts[:chdir] ? only(opts, :chdir) : nil].compact
        out, err, status = Open3.capture3(cmd, *opts)
        [out, err, status.success?]
      end

      # Runs a shell command, streaming any stdout or stderr output, and
      # returning the exit status
      #
      # This is the default method for executing shell commands. The stdout and
      # stderr will not be captured, but streamed directly to the parent process.
      #
      # @option chdir [String] directory temporarily to change to before running the command
      def system(cmd, opts = {})
        opts = [opts[:chdir] ? only(opts, :chdir) : nil].compact
        Kernel.system(cmd, *opts)
        ['', '', last_process_status]
      end

      # Whether or not the last executed shell command was successful.
      def success?
        !!@last_status
      end

      # Whether or not the last executed shell command has failed.
      def failed?
        !success?
      end

      # Returns the last child process' exit status
      #
      # Internal, and not to be used by implementors. $? is a read-only
      # variable, so we use a method that we can stub during tests.
      def last_process_status
        $CHILD_STATUS.success?
      end

      # Whether or not the current Ruby process runs with superuser priviledges.
      def sudo?
        Process::UID.eid.zero?
      end

      # Returns current repository name
      #
      # Uses the environment variable `TRAVIS_REPO_SLUG` if present, or the
      # current directory's base name.
      #
      # Note that this might return an unexpected string outside of the context
      # of Travis CI build environments if the method is called at a time when
      # the current working directory has changed.
      def repo_name
        ENV['TRAVIS_REPO_SLUG'] ? ENV['TRAVIS_REPO_SLUG'].split('/').last : File.basename(Dir.pwd)
      end

      # Returns current repository slug
      #
      # Uses the environment variable `TRAVIS_REPO_SLUG` if present, or the
      # last two segmens of the current working directory's path.
      #
      # Note that this might return an unexpected string outside of the context
      # of Travis CI build environments if the method is called at a time when
      # the current working directory has changed.
      def repo_slug
        ENV['TRAVIS_REPO_SLUG'] || Dir.pwd.split('/')[-2, 2].join('/')
      end

      # Returns the current build directory
      #
      # Uses the environment variable `TRAVIS_REPO_SLUG` if present, and
      # defaults to `.` otherwise.
      #
      # Note that this might return an unexpected string outside of the context
      # of Travis CI build environments if the method is called at a time when
      # the current working directory has changed.
      def build_dir
        ENV['TRAVIS_BUILD_DIR'] || '.'
      end

      # Returns the current build number
      #
      # Returns the value of the environment variable `TRAVIS_BUILD_NUMBER` if
      # present.
      def build_number
        ENV['TRAVIS_BUILD_NUMBER'] || raise('TRAVIS_BUILD_NUMBER not set')
      end

      # Returns the encoding of the given file, as determined by `file`.
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

      # Returns the current branch name
      def git_branch
        ENV['TRAVIS_BRANCH'] || git_rev_parse('HEAD')
      end

      # Returns the message of the commit `git_sha`.
      def git_commit_msg
        `git log #{git_sha} -n 1 --pretty=%B`.chomp
      end

      # Returns the committer name of the commit `git_sha`.
      def git_author_name
        `git log #{git_sha} -n 1 --pretty=%an`.chomp
      end

      # Returns the comitter email of the commit `git_sha`.
      def git_author_email
        `git log #{git_sha} -n 1 --pretty=%ae`.chomp
      end

      # Whether or not the git working directory is dirty or has new or deleted files
      def git_dirty?
        !`git status --short`.chomp.empty?
      end

      # Returns the output of `git log`, using the given args.
      def git_log(args)
        `git log #{args}`.chomp
      end

      # Returns the Git log, separated by NULs
      #
      # Returns the output of `git ls-files -z`, which separates log entries by
      # NULs, rather than newline characters.
      def git_ls_files
        `git ls-files -z`.split("\x0")
      end

      # Returns true if the given ref exists remotely
      def git_ls_remote?(url, ref)
        Kernel.system("git ls-remote --exit-code #{url} #{ref} > /dev/null 2>&1")
      end

      # Returns known Git remote URLs
      def git_remote_urls
        `git remote -v`.scan(/\t[^\s]+\s/).map(&:strip).uniq
      end

      # Returns the sha for the given Git ref
      def git_rev_parse(ref)
        `git rev-parse #{ref}`.strip
      end

      # Returns the latest tag name, if any
      def git_tag
        `git describe --tags --exact-match 2>/dev/null`.chomp
      end

      # Returns the current commit sha
      def git_sha
        ENV['TRAVIS_COMMIT'] || `git rev-parse HEAD`.chomp
      end

      # Returns the local machine's hostname
      def machine_name
        `hostname`.strip
      end

      # Returns the current Node.js version
      def node_version
        `node -v`.sub(/^v/, '').chomp
      end

      # Returns the current NPM version
      def npm_version
        `npm --version`
      end

      # Returns the current Node.js version
      def python_version
        `python --version 2>&1`.sub(/^Python /, '').chomp
      end

      # Returns true or false depending if the given command can be found
      def which(cmd)
        !`which #{cmd}`.chomp.empty? if cmd
      end

      # Returns a unique temporary directory name
      def tmp_dir
        @tmp_dir ||= Dir.mktmpdir
      end

      # Returns the size of the given file path
      def file_size(path)
        File.size(path)
      end

      def move_files(paths)
        paths.each do |path|
          target = "#{tmp_dir}/#{File.basename(path)}"
          mv(path, target) if File.exist?(path)
        end
      end

      def unmove_files(paths)
        paths.each do |path|
          source = "#{tmp_dir}/#{File.basename(path)}"
          mv(source, path) if File.exist?(source)
        end
      end

      def mv(src, dest)
        Kernel.system("sudo mv #{src} #{dest} 2> /dev/null")
      end

      # Writes the given content to the given file path
      def write_file(path, content, chmod = nil)
        path = File.expand_path(path)
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, 'w+') { |f| f.write(content) }
        FileUtils.chmod(chmod, path) if chmod
      end

      # Writes the given machine, login, and password to ~/.netrc
      def write_netrc(machine, login, password)
        require 'netrc'
        netrc = Netrc.read
        netrc[machine] = [login, password]
        netrc.save
      end

      def sleep(sec)
        Kernel.sleep(sec)
      end

      def tty?
        $stdout.isatty
      end

      # Returns a copy of the given hash, reduced to the given keys
      def only(hash, *keys)
        hash.select { |key, _| keys.include?(key) }.to_h
      end

      def test?
        false
      end
    end
  end
end
