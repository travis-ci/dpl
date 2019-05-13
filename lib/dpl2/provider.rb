require 'cl'
require 'fileutils'
require 'forwardable'
require 'dpl2/provider/env'
require 'dpl2/provider/fold'

module Dpl
  # Providers are encouraged to implement any of the following stages:
  #
  #   * setup
  #   * check_auth
  #   * deploy
  #   * finish
  #
  # The main logic should sit in the deploy stage.
  #
  # The following stages are not meant to be overwritten, and for applying
  # default behaviour:
  #
  #   * before_setup
  #   * after_deploy
  #   * before_finish

  class Provider < Cl::Cmd
    extend Forwardable
    include Env, Fold, FileUtils

    class << self
      def experimental(msg = nil)
        msg ? @experimental = msg : @experimental
      end

      %i(deprecated needs_key).each do |flag|
        define_method(:"#{flag}?") { !!instance_variable_get(:"@#{flag}") }
        define_method(flag) { instance_variable_set(:"@#{flag}", true) }
      end

      %i(apt npm pip).each do |name|
        define_method(name) do |*args|
          args.any? ? instance_variable_set(:"@#{name}", args) : instance_variable_get(:"@#{name}")
        end
      end

      def keep(*paths)
        paths.any? ? keep.concat(paths) : @keep ||= KEEP.dup
      end

      def user_agent(*strs)
        strs.unshift "dpl/#{DPL::VERSION}"
        strs.unshift 'travis/0.1.0' if ENV['TRAVIS']
        strs = strs.flat_map { |e| Hash === e ? e.map { |k,v| "#{k}/#{v}" } : e }
        strs.join(' ').gsub(/\s+/, ' ').strip
      end
    end

    abstract

    opt '--run CMD', type: :array
    opt '--app NAME', default: :repo_name
    opt '--key_name NAME', default: :machine_name
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

    def_delegators :ctx, :repo_slug, :repo_name, :build_dir, :build_number,
      :error, :exists?, :fold, :script, :sleep, :success?, :git_tag, :remotes,
      :git_rev_parse, :commit_msg, :sha, :apt, :npm, :pip, :npm_version,
      :which, :encoding, :machine_name, :ssh_keygen, :logger, :tmpdir,
      :rendezvous

    def run
      before_install
      install
      check_auth
      login
      before_setup
      setup
      prepare
      validate
      before_deploy
      deploy
      after_deploy
    ensure
      before_finish
      finish
    end

    def before_install
      deprecated_opts.each { |(key, msg)| ctx.deprecate_opt(key, msg) }
      ctx.apt *self.class.apt if self.class.apt
      ctx.npm *self.class.npm if self.class.npm
      ctx.pip *self.class.pip if self.class.pip
    end

    def install
    end

    def login
    end

    def before_setup
      setup_dir
      setup_ssh if needs_key?
    end

    def setup
    end

    def validate
    end

    def before_deploy
      cleanup unless skip_cleanup?
    end
    fold :prepare

    def check_auth
    end

    def cleanup
      info MSGS[:cleanup]
      self.class.keep.each { |path| shell "mv ./#{path} ~/#{path}" }
      shell 'git stash --all'
      self.class.keep.each { |path| shell "mv ~/#{path} ./#{path}" }
    end

    def prepare
    end

    def deploy
      raise 'Overwrite this'
    end
    fold :deploy

    def after_deploy
      run_cmds if run?
    end

    def before_finish
      remove_key if needs_key?
      uncleanup unless skip_cleanup?
    end

    def uncleanup
      shell 'git stash pop'
    end

    def finish
    end

    def run_cmds
      opts[:run].each do |cmd|
        cmd == 'restart' ? restart : run_cmd(cmd)
      end
    end

    def run_cmd(cmd)
      shell(cmd)
    end
    fold :run_cmd

    def setup_dir
      rm_rf '.dpl'
      mkdir_p '.dpl'
    end

    def needs_key?
      self.class.needs_key?
    end

    def setup_ssh
      ssh_keygen(key_name, '.dpl/id_rsa')
      setup_git_ssh('.dpl/git-ssh', '.dpl/id_rsa')
      setup_key('.dpl/id_rsa.pub')
    end

    def setup_key
      # overwrite this
    end

    def setup_git_credentials
      shell "git config user.email >/dev/null 2>/dev/null || git config user.email `whoami`@localhost"
      shell "git config user.name  >/dev/null 2>/dev/null || git config user.name  `whoami`"
    end

    def setup_git_ssh(path, key)
      path, key = File.expand_path(path), File.expand_path(key)
      File.open(path, 'w+') { |file| file.write(FILES[:git_ssh] % key) }
      chmod(0740, path)
      ENV['GIT_SSH'] = path
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

    def remove_key
    end

    def name
      registry_key
    end

    def user_agent
      self.class.user_agent
    end

    def shell(cmd, *args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      opts[:assert] = interpolate(self.class::ASSERT[cmd], args) if opts[:assert].is_a?(TrueClass)
      cmd = interpolate(self.class::CMDS[cmd], args).strip if cmd.is_a?(Symbol)
      ctx.shell(cmd, opts)
    end

    def error(msg, *args)
      msg = interpolate(self.class::MSGS[msg], args) if msg.is_a?(Symbol)
      ctx.error msg
    end

    def warn(msg, *args)
      msg = interpolate(self.class::MSGS[msg], args) if msg.is_a?(Symbol)
      ctx.warn msg
    end

    def info(msg, *args)
      msg = interpolate(self.class::MSGS[msg], args) if msg.is_a?(Symbol)
      ctx.info msg
    end

    def print(msg, *args)
      msg = interpolate(self.class::MSGS[msg], args) if msg.is_a?(Symbol)
      ctx.print msg
    end

    def interpolate(str, args = [])
      args = Hash.new { |_, key| send(key).to_s } if args.empty?
      str % args
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

    def quote(str)
      %("#{str}")
    end

    def obfuscate(str)
      str[-4..-1].to_s.rjust(20, '*')
    end

    def compact(hash)
      hash.reject { |_, value| value.nil? }
    end
  end
end

require 'dpl2/providers'
