require 'cl'
require 'fileutils'
require 'forwardable'
require 'shellwords'
require 'dpl/helper/assets'
require 'dpl/helper/cmd'
require 'dpl/helper/config_file'
require 'dpl/helper/env'
require 'dpl/helper/interpolate'
require 'dpl/helper/memoize'
require 'dpl/helper/squiggle'
require 'dpl/provider/dsl'
require 'dpl/provider/examples'
require 'dpl/version'

module Dpl
  # Base class for all concrete providers that `dpl` supports.
  #
  # These are subclasses of `Cl::Cmd` which means they are going to be detected
  # by the first argument passed to `dpl [provider]`, instantiated, and run.
  #
  # Implementors are encouraged to use the provider DSL to declare various
  # features, requirements, and attributes that apply to their provider, to
  # implement any of the following stages (methods) according to their needs
  # and semantics:
  #
  #   * init
  #   * install
  #   * login
  #   * setup
  #   * validate
  #   * prepare
  #   * deploy
  #   * finish
  #
  # The main logic should sit in the `deploy` stage.
  #
  # If at any time the method `error` is called, or any exception raised the
  # deploy process will be halted, and subsequent stages skipped. However, the
  # stage `finish` will run even if previous stages have raised an error,
  # giving the provider the opportunity to potentially clean up stage.
  #
  # In addition to this the following methods will be called if implemented
  # by the provider:
  #
  #   * run_cmd
  #   * add_key
  #   * remove_key
  #
  # Like the `finish` stage, the method `remove_key` will be called even if
  # previous stages have raised an error.
  #
  # See the respective method's documentation for details on these.
  #
  # The following stages are not meant to be overwritten, but considered
  # internal:
  #
  #   * before_install
  #   * before_setup
  #   * before_prepare
  #   * before_finish
  #
  # Dependencies declared as required, such as APT, NPM, or Python are going to
  # be installed as part of the `before_install` stage .
  #
  # Cleanup is run as part of the `before_prepare` stage if the option
  # `--cleanup` was given. This will use `git stash --all` in order to reset
  # the working directory to the committed state, and cleanup any left over
  # artifacts from the build process. Providers can use the DSL method `keep`
  # in order to declare known artifacts (such as CLI tooling installed to the
  # working directory) that needs to be moved out of the way and restored after
  # the cleanup process. (It is recommended to place such artifacts outside of
  # the build working directory though, for example in `~/.dpl`).
  #
  # The method `run_cmd` is called for each command specified using the `--run`
  # option. By default, these command are going to be run as local shell
  # commands, but providers can choose to overwrite this method in order to run
  # the command on a remote machine.
  #
  # @see https://github.com/svenfuchs/cl Cl's documentation for details on how
  # providers (commands) are declared and run.

  class Provider < Cl::Cmd
    extend Dsl, Forwardable
    include Assets, Env, ConfigFile, FileUtils, Interpolate, Memoize, Squiggle

    class << self
      def examples
        @examples ||= super || Examples.new(self).cmds
      end

      def move_files(ctx)
        ctx.move_files(move) if move.any?
      end

      def unmove_files(ctx)
        ctx.unmove_files(move) if move.any?
      end

      def install_deps?
        apt? || gem? || npm? || pip?
      end

      def install_deps(ctx)
        ctx.apts_get(apt) if apt?
        ctx.gems_require(gem) if gem?
        npm.each { |npm| ctx.npm_install *npm } if npm?
        pip.each { |pip| ctx.pip_install *pip } if pip?
      end

      def validate_runtimes(ctx)
        ctx.validate_runtimes(runtimes) if runtimes.any?
      end
    end

    # Fold names to display in the build log.
    FOLDS = {
      init:     'Initialize deployment',
      setup:    'Setup deployment',
      validate: 'Validate deployment',
      install:  'Install deployment dependencies',
      login:    'Authenticate deployment',
      prepare:  'Prepare deployment',
      deploy:   'Run deployment',
      finish:   'Finish deployment',
    }

    # Deployment process stages.
    #
    # In addition to the stages listed here the stage `finish` will be run at
    # the end of the process.
    #
    # Also, the methods `add_key` (called before `setup`), `remove_key` (called
    # before `finish`), and `run_cmd` (called after `deploy`) may be of
    # interest to implementors.
    STAGES = %i(
      init
      install
      login
      setup
      validate
      prepare
      deploy
    )

    abstract

    opt '--cleanup',      'Clean up build artifacts from the Git working directory before the deployment', negate: %w(skip)
    opt '--run CMD',      'Commands to execute after the deployment finished successfully', type: :array
    opt '--stage NAME',   'Execute the given stage(s) only', type: :array, internal: true, default: STAGES
    opt '--backtrace',    'Print the backtrace for exceptions', internal: true
    opt '--fold',         'Wrap log output in folds', internal: true
    opt '--edge',         internal: true

    vars *%i(
      git_author_email
      git_author_name
      git_branch
      git_commit_author
      git_commit_msg
      git_sha
      git_tag
    )

    msgs before_install:  'Installing deployment dependencies',
         before_setup:    'Setting the build environment up for the deployment',
         setup_git_ssh:   'Setting up git-ssh',
         cleanup:         'Cleaning up git repository with `git stash --all`',
         ssh_keygen:      'Generating SSH key',
         setup_git_ua:    'Setting up git HTTP user agent',
         ssh_remote_host: 'SSH remote is %s at port %s',
         ssh_try_connect: 'Waiting for SSH connection ...',
         ssh_connected:   'SSH connection established.',
         ssh_failed:      'Failed to establish SSH connection.'

    def_delegators :'self.class', :status, :full_name, :install_deps,
      :install_deps?, :keep, :move_files, :unmove_files, :needs?, :runtimes,
      :validate_runtimes, :user_agent

    def_delegators :ctx, :apt_get, :gem_require, :npm_install, :pip_install,
      :build_dir, :build_number, :encoding, :file_size, :git_author_email,
      :git_author_name, :git_branch, :git_branch, :git_commit_author,
      :git_commit_msg, :git_commit_msg, :git_dirty?, :git_log, :git_log,
      :git_ls_files, :git_ls_remote?, :git_remote_urls, :git_remote_urls,
      :git_rev_parse, :git_rev_parse, :git_sha, :git_tag, :last_err, :last_out,
      :last_out, :logger, :machine_name, :mv, :node_version, :node_version,
      :npm_version, :rendezvous, :rendezvous, :repo_slug, :sleep, :sleep,
      :ssh_keygen, :success?, :test?, :test?, :tmp_dir, :tty?, :which, :which,
      :write_file, :write_netrc

    attr_reader :repo_name, :key_name

    def initialize(ctx, *args)
      @repo_name = ctx.repo_name
      @key_name = ctx.machine_name
      super
    end

    # Runs all stages, all commands provided by the user, as well as the final
    # stage `finish` (which will be run even if an error has been raised during
    # previous stages).
    def run
      stages = stage.select { |stage| run_stage?(stage) }
      stages.each { |stage| run_stage(stage) }
      run_cmds
    rescue Error
      raise
    rescue Exception => e
      raise Error.new("#{e.message} (#{e.class})", backtrace: backtrace? ? e.backtrace : nil) unless test?
      raise
    ensure
      run_stage(:finish, fold: false) if finish?
    end

    # Whether or not a stage needs to be run
    def run_stage?(stage)
      respond_to?(:"before_#{stage}") || respond_to?(stage)
    end

    def finish?
      stage.size == STAGES.size
    end

    # Runs a single stage.
    #
    # For each stage the base class has the opportunity to implement a `before`
    # stage method, in order to apply default behaviour. Provider implementors
    # are asked to not overwrite these methods.
    #
    # Any log output from both the before stage and stage method is going to be
    # folded in the resulting build log.
    def run_stage(stage, opts = {})
      fold(stage, opts) do
        send(:"before_#{stage}") if respond_to?(:"before_#{stage}")
        send(stage) if respond_to?(stage)
      end
    end

    # Initialize the deployment process.
    #
    # This will:
    #
    # * Displays warning messages about the provider's maturity status, and deprecated
    #   options used.
    # * Setup a ~/.dpl working directory
    # * Move files out of the way that have been declared as such
    def before_init
      warn status.msg if status && status.announce?
      deprecations.each { |(key, msg)| ctx.deprecate_opt(key, msg) }
      setup_dpl_dir
      move_files(ctx)
    end

    # Install APT, NPM, and Python dependencies as declared by the provider.
    def before_install
      validate_runtimes(ctx)
      return unless install_deps?
      info :before_install
      install_deps(ctx)
    end

    # Sets the build environment up for the deployment.
    #
    # This will:
    #
    # * Setup a ~/.dpl working directory
    # * Create a temporary, per build SSH key, and call `add_key` if the feature `ssh_key` has been declared as required.
    # * Setup git config (email and user name) if the feature `git` has been declared as required.
    # * Either set or unset the environment variable `GIT_HTTP_USER_AGENT` depending if the feature `git_http_user_agent` has been declared as required.
    def before_setup
      info :before_setup
      setup_ssh_key if needs?(:ssh_key)
      setup_git_config if needs?(:git)
      setup_git_http_user_agent
    end

    # Prepares the deployment by cleaning up the working directory.
    #
    # @see Provider#cleanup
    def before_prepare
      cleanup if cleanup?
    end

    # Runs each command as given by the user using the `--run` option.
    #
    # For a command that matches `restart` the method `restart` will be called
    # (which can be overwritten by providers, e.g. in order to restart service
    # instances).
    #
    # All other commands will be passed to the method `run_cmd`. By default this
    # will be run as a shell command locally, but providers can choose to
    # overwrite this method in order to run the command on a remote machine.
    def run_cmds
      Array(opts[:run]).each do |cmd|
        cmd.downcase == 'restart' ? restart : run_cmd(cmd)
      end
    end

    def run_cmd(cmd)
      cmd.downcase == 'restart' ? restart : shell(cmd)
    end

    # Finalizes the deployment process.
    #
    # This will:
    #
    # * Call the method `remove_key` if implemented by the provider, and if the
    #   feature `ssh_key` has been declared as required.
    # * Revert the cleanup process, i.e. restore files moved out of the way
    #   during `cleanup`.
    # * Remove the temporary directory `~/.dpl`
    def before_finish
      remove_key if needs?(:ssh_key) && respond_to?(:remove_key)
      uncleanup if cleanup?
      unmove_files(ctx)
      remove_dpl_dir
    end

    # Resets the current working directory to the commited state.
    #
    # Cleanup will use `git stash --all` in order to reset the working
    # directory to the committed state, and cleanup any left over artifacts
    # from the build process. Providers can use the DSL method `keep` in order
    # to declare known artifacts (such as CLI tooling installed to the working
    # directory) that needs to be moved out of the way and restored after the
    # cleanup process.
    def cleanup
      info :cleanup
      keep.each { |path| shell "mv ./#{path} ~/#{path}", echo: false, assert: false }
      shell 'git stash --all'
      keep.each { |path| shell "mv ~/#{path} ./#{path}", echo: false, assert: false }
    end

    # Restore files that have been cleaned up.
    def uncleanup
      shell 'git stash pop', assert: false
    end

    # Creates the directory `~/.dpl` as an internal working directory.
    def setup_dpl_dir
      rm_rf '~/.dpl'
      mkdir_p '~/.dpl'
      chmod 0700, '~/.dpl'
    end

    # Remove the internal working directory `~/.dpl`.
    def remove_dpl_dir
      rm_rf '~/.dpl'
    end

    # Creates an SSH key, and sets up git-ssh if needed.
    #
    # This will:
    #
    # * Create a temporary, per build SSH key.
    # * Setup a `git-ssh` executable to use that key.
    # * Call the method `add_key` if implemented by the provider.
    def setup_ssh_key
      ssh_keygen(key_name, '~/.dpl/id_rsa')
      setup_git_ssh('~/.dpl/id_rsa')
      add_key('~/.dpl/id_rsa.pub') if respond_to?(:add_key)
    end

    # Setup git config
    #
    # This adds the current user's name and email address (as user@localhost)
    # to the git config.
    def setup_git_config
      shell "git config user.email >/dev/null 2>/dev/null || git config user.email `whoami`@localhost", echo: false, assert: false
      shell "git config user.name  >/dev/null 2>/dev/null || git config user.name  `whoami`", echo: false, assert: false
    end

    # Sets up `git-ssh` and the GIT_SSH env var
    def setup_git_ssh(key)
      info :setup_git_ssh
      path, conf = '~/.dpl/git-ssh', asset(:dpl, :git_ssh).read % expand(key)
      open(path, 'w+') { |file| file.write(conf) }
      chmod(0740, path)
      ENV['GIT_SSH'] = expand(path)
    end

    # Generates an SSH key.
    def ssh_keygen(key, path)
      info :ssh_keygen
      ctx.ssh_keygen(key, expand(path))
    end

    # Sets or unsets the environment variable `GIT_HTTP_USER_AGENT`.
    def setup_git_http_user_agent
      return ENV.delete('GIT_HTTP_USER_AGENT') unless needs?(:git_http_user_agent)
      info :setup_git_ua
      ENV['GIT_HTTP_USER_AGENT'] = user_agent(git: `git --version`[/[\d\.]+/])
    end

    # Waits for SSH access on the given host and port.
    #
    # This will try to connect to the given SSH host and port, and keep
    # retrying 30 times, waiting a second inbetween retries.
    def wait_for_ssh_access(host, port)
      info :ssh_remote_host, host, port
      1.upto(20) { try_ssh_access(host, port) && break || sleep(3) }
      success? ? info(:ssh_connected) : error(:ssh_failed)
    end

    # Tries to connect to the given SSH host and port.
    def try_ssh_access(host, port)
      info :ssh_try_connect
      shell "#{ENV['GIT_SSH']} #{host} -p #{port} 2>&1 | grep -c 'PTY allocation request failed' > /dev/null", echo: false, assert: false
    end

    # Creates a log fold.
    #
    # Folds any log output from the given block into a fold with the given
    # name.
    def fold(name, opts = {}, &block)
      return yield unless fold?(name, opts)
      title = FOLDS[name] || "deploy.#{name}"
      ctx.fold(title, &block)
    end

    # Checks if the given stage needs to be folded.
    #
    # Depends on the option `--fold`, also omits folds for the init and finish
    # stages. Can be overwritten by passing `fold: false`.
    def fold?(name, opts = {})
      !opts[:fold].is_a?(FalseClass) && super() && !%i(init).include?(name)
    end

    # Runs a script as a shell command.
    #
    # Scripts can be stored as separate files (assets) in the directory
    # `lib/dpl/assets/[provider]`.
    #
    # This is meant for large shell commands that would be hard to read if
    # embedded in Ruby code. Storing them as separate files helps with proper
    # syntax highlighting etc in editors, and allows to execute them for
    # testing purposes.
    #
    # Scripts can have interpolation variables. See Dpl::Interpolate for
    # details on interpolating variables.
    #
    # See Ctx::Bash#shell for details on the options accepted.
    def script(name, opts = {})
      opts[:assert] = name if opts[:assert].is_a?(TrueClass)
      shell(asset(name).read, opts.merge(echo: false))
    end

    # Runs a single shell command.
    #
    # Shell commands can have interpolation variables. See Dpl::Interpolate for
    # details on interpolating variables.
    #
    # See Ctx::Bash#shell for details on the options accepted.
    def shell(cmd, *args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      cmd = Cmd.new(self, cmd, opts)
      ctx.shell(cmd)
    end

    # @!method print
    # Prints a partial message to stdout
    #
    # This method does not append a newline character to the given message,
    # which usually is not the desired behaviour. The method is intended to be
    # used if an initial, partial message is supposed to be printed, which will
    # be completed later (using the method `info`).
    #
    # For example:
    #
    #   print 'Starting a long running task ...'
    #   run_long_running_task
    #   info 'done.'
    #
    # Messages support interpolation variables. See Dpl::Interpolate for
    # details on interpolating variables.

    # @!method info
    # Outputs an info message to stdout
    #
    # This method is intended to be used for default, info level messages that
    # are supposed to show up in the build log.
    #
    # @!method warn
    # Outputs an warning message to stderr
    #
    # This method is intended to be used for warning messages that are supposed
    # to show up in the build log, but do not qualify as errors that would
    # abort the deployment process. The warning will be highlighted as red
    # text. Use sparingly.
    #
    # Messages support interpolation variables. See Dpl::Interpolate for
    # details on interpolating variables.

    # @!method error
    # Outputs an error message to stderr, and raises an error, halting the
    # deployment process.
    #
    # This method is intended to be used for all error conditions that require
    # the deployment process to be aborted.
    #
    # Messages support interpolation variables. See Dpl::Interpolate for
    # details on interpolating variables.
    %i(print info warn error).each do |level|
      define_method(level) do |msg, *args|
        msg = interpolate(self.msg(msg), args) if msg.is_a?(Symbol)
        ctx.send(level, msg)
      end
    end

    # @!method cmd
    # Looks up a shell command from the commands declared by the provider
    # (using the class level DSL).
    #
    # Not usually useful to be used by provider implementors directly. Use the
    # method `shell` in order to execute shell commands.

    # @!method err
    # Looks up an error message from the error messages declared by the
    # provider (using the class level DSL), as needed by the option `assert`
    # when passed to the method `shell`.

    # @!method msg
    # Looks up a message from the messages declared by the provider (using the
    # class level DSL).
    #
    # For example, a message declared on the class body like so:
    #
    #   ```ruby
    #   msgs commit_msg: 'Commit build artifacts on build %{build_number}'
    #   ```
    #
    # could be used by the implementation like so:
    #
    #   ```ruby
    #   def commit_msg
    #     interpolate(msg(:commit_msg))
    #   end
    #   ```
    #
    # Note that the the method `interpolate` needs to be used in order to
    # interpolate variables used in a message (if any).
    %i(cmd err msg str).each do |name|
      define_method(name) do |*keys|
        key = keys.detect { |key| key.is_a?(Symbol) }
        self.class.send(:"#{name}s")[key] if key
      end
    end

    # Escapes the given string so it can be safely used in Bash.
    def escape(str)
      Shellwords.escape(str)
    end

    # Double quotes the given string.
    def quote(str)
      %("#{str.to_s.gsub('"', '\"')}")
    end

    # Outdents the given string.
    #
    # @see Dpl::Squiggle
    def sq(str)
      self.class.sq(str)
    end

    # Generate shell option strings to be passed to a shell command.
    #
    # This generates strings like `--key="value"` for the option keys passed.
    # These keys are supposed to correspond to methods on the provider
    # instance, which will be called in order to determine the option value.
    #
    # If the returned value is an array then the option will be repeated
    # multiple times. If it is a String then it will be double quoted.
    # Otherwise it is assumed to be a flag that does not have a value.
    #
    # @option prefix [String] Use this to set a single dash as an option prefix (defaults to two dashes).
    # @option dashed [Boolean] Use this to dasherize the option key (rather than underscore it, defaults to underscore).
    def opts_for(keys, opts = {})
      strs = Array(keys).map { |key| opt_for(key, opts) if send(:"#{key}?") }.compact
      strs.join(' ') if strs.any?
    end

    def opt_for(key, opts = {})
      case value = send(key)
      when String then "#{opt_key(key, opts)}=#{value.inspect}"
      when Array  then value.map { |value| "#{opt_key(key, opts)}=#{value.inspect}" }
      else opt_key(key, opts)
      end
    end

    def opt_key(key, opts)
      "#{opts[:prefix] || '--'}#{opts[:dashed] ? key.to_s.gsub('_', '-') : key}"
    end

    # Compacts the given hash by rejecting nil values.
    def compact(hash)
      hash.reject { |_, value| value.nil? }
    end

    # Returns a new hash with the given keys selected from the given hash.
    def only(hash, *keys)
      hash.select { |key, _| keys.include?(key) }
    end

    # Deep symbolizes the given hash's keys
    def symbolize(obj)
      case obj
      when Hash
        obj.map { |key, obj| [key.to_sym, symbolize(obj)] }.to_h
      when Array
        obj.map { |obj| symbolize(obj) }
      else
        obj
      end
    end

    def file?(path)
      File.file?(expand(path))
    end

    def mkdir_p(path)
      FileUtils.mkdir_p(expand(path))
    end

    def chmod(perm, path)
      super(perm, expand(path))
    end

    def mv(src, dest)
      super(expand(src), expand(dest))
    end

    def rm_rf(path)
      super(expand(path))
    end

    def open(path, *args, &block)
      File.open(expand(path), *args, &block)
    end

    def read(path)
      File.read(expand(path))
    end

    def expand(*args)
      File.expand_path(*args)
    end
  end
end

require 'dpl/providers'
