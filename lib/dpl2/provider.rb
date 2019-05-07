require 'cl'
require 'forwardable'
require 'dpl2/provider/env'
require 'dpl2/provider/fold'

module Dpl
  # Providers are encouraged to implement any of the following stages:
  #
  #   * setup
  #   * check_auth
  #   * check_app
  #   * deploy
  #   * finish
  #
  # The main logic should sit in the deploy stage.
  #
  # Minimal providers that only need to execute a single command can skip
  # implementing the `deploy` method, and only implement a method `cmd`, which
  # will be picked up by the base implemention here.
  #
  # The following stages are not meant to be overwritten, and for applying
  # default behaviour:
  #
  #   * before_setup
  #   * after_deploy
  #   * before_finish

  class Provider < Cl::Cmd
    extend Forwardable
    include Env, Fold

    abstract

    opt '--run', type: :array
    opt '--app', default: File.basename(Dir.pwd)
    opt '--key_name', default: `hostname`.strip
    opt '--skip-cleanup'
    # opt '--pretend', 'Pretend running the deployment'
    # opt '--quiet',   'Suppress any output'

    def_delegators :ctx, :error, :fold, :script, :shell, :info, :warn, :success?

    def run
      before_setup
      setup
      install
      deploy
      after_deploy
    ensure
      before_finish
      finish
    end

    def setup
    end

    def before_setup
      # Setup.new(ctx).setup
      check_auth
      check_app
      cleanup unless skip_cleanup?
    end
    fold :prepare

    def check_app
    end

    def check_auth
    end

    def install
    end

    def cleanup
      # WorkDir.new(ctx).cleanup
    end

    def deploy
      shell cmd
    end
    fold :deploy

    def after_deploy
      Array(opts[:run]).each { |cmd| run_cmd(cmd) }
    end

    def before_finish
      remove_key if needs_key?
      # WorkDir.new(ctx).uncleanup
    end

    def finish
    end

    def run_cmd(cmd)
      shell cmd
    end
    fold :run_cmd

    def needs_key?
      true
    end

    def remove_key
    end

    def name
      registry_key
    end

    def deprectated_opt(old, new)
      ctx.deprecate_opt(old, new)
      opts[old]
    end

    def opts_for(keys, dash = '--')
      opts = keys.map { |key| opt_for(key, dash) if send(:"#{key}?") }.compact
      opts.join(' ') if opts.any?
    end

    def opt_for(key, dash)
      case value = send(key)
      when String then "#{dash}#{key}=#{value.inspect}"
      when Array  then value.map { |value| "#{dash}#{key}=#{value.inspect}" }
      else "#{dash}#{key}"
      end
    end

    def quote(str)
      %("#{str}")
    end
  end
end

require 'dpl2/providers'
