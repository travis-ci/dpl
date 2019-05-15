require 'cl'
require 'fileutils'
require 'forwardable'
require 'shellwords'
require 'dpl/provider/assets'
require 'dpl/provider/env'
require 'dpl/provider/interpolate'
require 'dpl/provider/require'

module Dpl
  # Providers are encouraged to implement any of the following stages
  # according to their needs and semantics.
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
  # The main logic should sit in the :deploy stage. The stage :finish will run
  # even if previous stages have raised an error, and caused other stages to be
  # skipped (i.e. the deploy process to be halted).
  #
  # The following stages are not meant to be overwritten, but considered
  # internal:
  #
  #   * before_install
  #   * before_setup
  #   * before_deploy
  #   * before_finish

  class Provider < Cl::Cmd
    extend Forwardable
    include Assets, Env, FileUtils, Interpolate

    class << self
      %i(cleanup deprecated experimental).each do |name|
        define_method(:"#{name}?") { !!instance_variable_get(:"@#{name}") }
        define_method(name) { |arg = true| instance_variable_set(:"@#{name}", arg) }
      end

      %i(apt npm pip).each do |name|
        define_method(:"#{name}?") { !!instance_variable_get(:"@#{name}") }
        define_method(name) { |*args| args.any? ? instance_variable_set(:"@#{name}", args) : instance_variable_get(:"@#{name}") }
      end

      def full_name(name = nil)
        name ? @full_name = name : @full_name || self.name.split('::').last
      end

      def summary(summary = nil)
        summary ? super : @summary || "#{full_name} deployment provider"
      end

      def cmds(cmds = nil)
        return self.cmds.update(cmds) if cmds
        @cmds ||= self == Provider ? {} : superclass.cmds.dup
      end

      def errs(errs = nil)
        return self.errs.update(errs) if errs
        @errs ||= self == Provider ? {} : superclass.errs.dup
      end

      def msgs(msgs = nil)
        return self.msgs.update(msgs) if msgs
        @msgs ||= self == Provider ? {} : superclass.msgs.dup
      end

      def keep(*paths)
        paths.any? ? keep.concat(paths) : @keep ||= []
      end

      def needs?(feature)
        needs.include?(feature)
      end

      def needs(*features)
        features.any? ? needs.concat(features) : @needs ||= []
      end

      def requires(*paths)
        paths.any? ? requires.concat(paths) : @requires ||= []
      end

      def require(ctx)
        Require.new(ctx, self).run
      end

      def user_agent(*strs)
        strs.unshift "dpl/#{Dpl::VERSION}"
        strs.unshift 'travis/0.1.0' if ENV['TRAVIS']
        strs = strs.flat_map { |e| Hash === e ? e.map { |k, v| "#{k}/#{v}" } : e }
        strs.join(' ').gsub(/\s+/, ' ').strip
      end

      # Beloved squiggly heredocs did not existin Ruby 2.1.0, which we still
      # want to support, so let's give kudos with this method in the meantime.
      def sq(str)
        width = str =~ /( *)\S/ && $1.size
        str.lines.map { |line| line.gsub(/^ {#{width}}/, '') }.join
      end
    end

    abstract

    opt '--app NAME',      default: :repo_name
    opt '--key_name NAME', default: :machine_name
    opt '--run CMD',       type: :array
    opt '--skip_cleanup'
    # opt '--pretend', 'Pretend running the deployment'
    # opt '--quiet',   'Suppress any output'

    msgs cleanup: 'Cleaning up git repository with `git stash --all`. If you need build artifacts for deployment, set `deploy.skip_cleanup: true`. See https://docs.travis-ci.com/user/deployment#Uploading-Files-and-skip_cleanup.',
         experimental: '%s support is experimental'

    KEEP = %w(.dpl)

    # FILES = {
    #   git_ssh: <<~file
    #     #!/bin/sh
    #     exec ssh -o StrictHostKeychecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null -i %s -- "$@"
    #   file
    # }

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

    STAGES = %i(
      init
      install
      login
      setup
      validate
      prepare
      deploy
    )

    def_delegators :'self.class', :apt, :npm, :pip, :experimental,
      :experimental?, :keep, :needs?, :user_agent

    def_delegators :ctx, :apt_get, :npm_install, :pip_install, :build_dir,
      :build_number, :repo_slug, :encoding, :git_commit_msg, :git_log,
      :git_ls_files, :git_remote_urls, :git_rev_parse, :git_sha, :git_tag,
      :machine_name, :npm_version, :sleep, :ssh_keygen, :success?, :tmp_dir,
      :which, :logger, :rendezvous

    attr_reader :repo_name

    def initialize(ctx, *)
      @repo_name = ctx.repo_name
      super
    end

    def run
      run_stages
      run_cmds
    ensure
      run_stage(:finish)
    end

    def run_stages
      STAGES.each do |stage|
        run_stage(stage) if run_stage?(stage)
      end
    end

    def run_stage?(stage)
      respond_to?(:"before_#{stage}") || respond_to?(stage)
    end

    def run_stage(stage)
      fold(stage) do
        send(:"before_#{stage}") if respond_to?(:"before_#{stage}")
        send(stage) if respond_to?(stage)
      end
    end

    def before_init
      warn msg(:experimental) % experimental if experimental?
      deprecated_opts.each { |(key, msg)| ctx.deprecate_opt(key, msg) }
      self.class.require(ctx)
    end

    def before_install
      info 'Installing deployment dependencies' if apt || npm || pip
      apt_get *apt if apt
      npm_install *npm if npm
      pip_install *pip if pip
    end

    def before_setup
      info 'Setting the build environment up for the deployment'
      setup_dpl_dir
      setup_ssh_key if needs?(:ssh_key)
      setup_git_config if needs?(:git)
      setup_git_http_user_agent
    end

    def before_prepare
      cleanup unless skip_cleanup?
    end

    def run_cmds
      Array(opts[:run]).each do |cmd|
        cmd == 'restart' ? restart : run_cmd(cmd)
      end
    end

    def run_cmd(cmd)
      cmd == 'restart' ? restart : shell(cmd)
    end

    def before_finish
      remove_key if needs?(:ssh_key) && respond_to?(:remove_key)
      uncleanup unless skip_cleanup?
    end

    def cleanup
      info :cleanup
      keep.each { |path| shell "mv ./#{path} ~/#{path}" }
      shell 'git stash --all'
      keep.each { |path| shell "mv ~/#{path} ./#{path}" }
    end

    def uncleanup
      shell 'git stash pop'
    end

    def name
      registry_key
    end

    def setup_dpl_dir
      rm_rf '.dpl'
      mkdir_p '.dpl'
    end

    def setup_ssh_key
      ssh_keygen(key_name, '.dpl/id_rsa')
      setup_git_ssh('.dpl/id_rsa')
      add_key('.dpl/id_rsa.pub') if respond_to?(:add_key)
    end

    def setup_git_config
      shell "git config user.email >/dev/null 2>/dev/null || git config user.email `whoami`@localhost"
      shell "git config user.name  >/dev/null 2>/dev/null || git config user.name  `whoami`"
    end

    def setup_git_ssh(key)
      info 'Setting up git-ssh'
      file, key = File.expand_path('.dpl/git-ssh'), File.expand_path(key)
      File.open(file, 'w+') { |file| file.write(asset(:dpl, :git_ssh).read % key) }
      chmod(0740, file)
      ENV['GIT_SSH'] = file
    end

    def ssh_keygen(*args)
      info 'Generating SSH key'
      ctx.ssh_keygen(*args)
    end

    def setup_git_http_user_agent
      return ENV.delete('GIT_HTTP_USER_AGENT') unless needs?(:git_http_user_agent)
      info 'Setting up git HTTP user agent'
      ENV['GIT_HTTP_USER_AGENT'] = user_agent(git: `git --version`[/[\d\.]+/])
    end

    def wait_for_ssh_access(host, port)
      info "Git remote is #{host} at port #{port}"
      1.upto(30) { try_ssh_access(host, port) && break || sleep(1) }
      success? ? info('SSH connection established.') : error('Failed to establish SSH connection.')
    end

    def try_ssh_access(host, port)
      info 'Waiting for SSH connection ...'
      shell "#{ENV['GIT_SSH']} #{host} -p #{port}  2>&1 | grep -c 'PTY allocation request failed' > /dev/null"
    end

    def fold(name, &block)
      title = FOLDS[name] || "deploy.#{name}"
      ctx.fold(title, &block)
    end

    def script(name, opts = {})
      opts[:assert] = name if opts[:assert].is_a?(TrueClass)
      shell(asset(name).read, opts)
    end

    def shell(cmd, *args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      opts[:assert] = interpolate(err(cmd, opts[:assert]), args) if opts[:assert].is_a?(TrueClass) || opts[:assert].is_a?(Symbol)
      cmd = interpolate(self.cmd(cmd), args).strip if cmd.is_a?(Symbol)
      ctx.shell(cmd, opts)
    end

    %i(print info warn error).each do |level|
      define_method(level) do |msg, *args|
        msg = interpolate(self.msg(msg), args) if msg.is_a?(Symbol)
        ctx.send(level, msg)
      end
    end

    %i(msg cmd err).each do |name|
      define_method(name) do |*keys|
        keys = keys.select { |key| key.is_a?(Symbol) }
        str = keys.map { |key| self.class.send(:"#{name}s")[key] }.first
        str || raise("Could not find #{name}: #{keys.join(', ')}")
      end
    end

    def escape(str)
      Shellwords.escape(str)
    end

    def obfuscate(str)
      str[-4, 4].to_s.rjust(20, '*')
    end

    def quote(str)
      %("#{str}")
    end

    def sq(str)
      self.class.sq(str)
    end

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

    def compact(hash)
      hash.reject { |_, value| value.nil? }
    end
  end
end

require 'dpl/providers'
