require 'cl'
require 'fileutils'
require 'forwardable'
require 'dpl2/provider/env'
require 'dpl2/provider/interpolation'
require 'dpl2/provider/fold'

module Dpl
  # Providers are encouraged to implement any of the following stages
  # according to their needs and semantics.
  #
  #   * init
  #   * install
  #   * login
  #   * setup
  #   * prepare
  #   * validate
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
    include Env, Fold, FileUtils

    class << self
      %i(cleanup deprecated).each do |flag|
        define_method(:"#{flag}?") { !!instance_variable_get(:"@#{flag}") }
        define_method(flag) { instance_variable_set(:"@#{flag}", true) }
      end

      %i(apt npm pip).each do |name|
        define_method(name) do |*args|
          args.any? ? instance_variable_set(:"@#{name}", args) : instance_variable_get(:"@#{name}")
        end
      end

      def experimental(msg = nil)
        msg ? @experimental = msg : @experimental
      end

      def needs?(need)
        needs.include?(need)
      end

      def needs(*features)
        features.any? ? needs.concat(features) : @needs ||= []
      end

      def keep(*paths)
        paths.any? ? keep.concat(paths) : @keep ||= KEEP.dup
      end

      def user_agent(*strs)
        strs.unshift "dpl/#{DPL::VERSION}"
        strs.unshift 'travis/0.1.0' if ENV['TRAVIS']
        strs = strs.flat_map { |e| Hash === e ? e.map { |k, v| "#{k}/#{v}" } : e }
        strs.join(' ').gsub(/\s+/, ' ').strip
      end
    end

    abstract

    opt '--app NAME',      default: :repo_name
    opt '--key_name NAME', default: :machine_name
    opt '--run CMD',       type: :array
    opt '--skip-cleanup'
    # opt '--pretend', 'Pretend running the deployment'
    # opt '--quiet',   'Suppress any output'

    KEEP = [
      '.dpl'
    ]

    FILES = {
      git_ssh: <<~file
        #!/bin/sh
        exec ssh -o StrictHostKeychecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null -i %s -- "$@"
      file
    }

    MSGS = {
      cleanup: <<~'msg',
        Cleaning up git repository with `git stash --all`.
        If you need build artifacts for deployment, set `deploy.skip_cleanup: true`.
        See https://docs.travis-ci.com/user/deployment#Uploading-Files-and-skip_cleanup.
      msg
    }

    STAGES = %i(
      init
      install
      login
      setup
      prepare
      validate
      deploy
    )

    def_delegators :'self.class', :keep, :needs?, :user_agent

    def_delegators :ctx, :repo_slug, :repo_name, :build_dir, :build_number,
      :error, :exists?, :fold, :script, :sleep, :success?, :git_tag, :remotes,
      :git_rev_parse, :commit_msg, :sha, :apt, :npm, :pip, :npm_version,
      :which, :encoding, :machine_name, :ssh_keygen, :logger, :tmpdir,
      :rendezvous

    def run
      run_stages
      run_cmds
    ensure
      run_stage(:finish)
    end

    def run_stages
      STAGES.each { |stage| run_stage(stage) }
    end

    def run_stage(stage)
      send(:"before_#{stage}") if respond_to?(:"before_#{stage}")
      send(stage) if respond_to?(stage)
    end

    def before_install
      deprecated_opts.each { |(key, msg)| ctx.deprecate_opt(key, msg) }
      ctx.apt *self.class.apt if self.class.apt
      ctx.npm *self.class.npm if self.class.npm
      ctx.pip *self.class.pip if self.class.pip
    end

    def before_setup
      setup_dpl_dir
      setup_ssh_key if needs?(:ssh_key)
      setup_git_config if needs?(:git)
      setup_git_http_user_agent
    end

    def before_deploy
      cleanup unless skip_cleanup?
    end
    fold :prepare

    def run_cmds
      Array(opts[:run]).each do |cmd|
        cmd == 'restart' ? restart : run_cmd(cmd)
      end
    end

    def run_cmd(cmd)
      cmd == 'restart' ? restart : shell(cmd)
    end
    fold :run_cmd

    def before_finish
      remove_key if needs?(:ssh_key)
      uncleanup unless skip_cleanup?
    end

    def cleanup
      info MSGS[:cleanup]
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
      setup_git_ssh_file('.dpl/id_rsa') if needs?(:git)
      ssh_keygen(key_name, '.dpl/id_rsa')
      add_key('.dpl/id_rsa.pub')
    end

    def setup_git_config
      shell "git config user.email >/dev/null 2>/dev/null || git config user.email `whoami`@localhost"
      shell "git config user.name  >/dev/null 2>/dev/null || git config user.name  `whoami`"
    end

    def setup_git_ssh_file(key)
      file, key = File.expand_path('.dpl/git-ssh'), File.expand_path(key)
      File.open(file, 'w+') { |file| file.write(FILES[:git_ssh] % key) }
      chmod(0740, file)
      ENV['GIT_SSH'] = file
    end

    def setup_git_http_user_agent
      return ENV.delete('GIT_HTTP_USER_AGENT') unless needs?(:git_http_user_agent)
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

    def shell(cmd, *args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      opts[:assert] = interpolate(self.class::ASSERT[cmd], args) if opts[:assert].is_a?(TrueClass)
      cmd = interpolate(self.class::CMDS[cmd], args).strip if cmd.is_a?(Symbol)
      ctx.shell(cmd, opts)
    end

    %i(print info warn error).each do |level|
      define_method(level) do |msg, *args|
        msg = interpolate(self.class::MSGS[msg], args) if msg.is_a?(Symbol)
        ctx.send(level, msg)
      end
    end

    def interpolate(str, args = [])
      args = Interpolation.new(self) if args.empty?
      str % args
    end

    def quote(str)
      %("#{str}")
    end

    def obfuscate(str)
      str[-4, 4].to_s.rjust(20, '*')
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

require 'dpl2/providers'
