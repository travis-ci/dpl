module Dpl
  # Represents a shell command
  class Cmd < Struct.new(:provider, :str, :opts)
    # Returns the shell command string
    #
    # The command will be interpolated, and can include secrets. See
    # `Dpl::Interpolate` for details on interpolating variables.
    #
    # If a Symbol was passed as a command then the command will be looked
    # up from the provider class' `cmds` declaration.
    #
    # If the option `silence` was passed then stdout and stderr will be
    # redirected to `/dev/null`.
    #
    # If the option `python` was passed then the virtualenv with the given
    # Python version will be activated before executing the command.
    def cmd
      cmd = lookup(:cmd, str) || error(:cmd, str)
      cmd = interpolate(cmd, opts, secure: true).strip
      cmd = silence(cmd) if silence?
      cmd = python(cmd) if python?
      cmd
    end

    # Returns the log message for announcing a command
    #
    # The message string will be interpolated, but included secrets will be
    # obfuscated. See `Dpl::Interpolate` for details on interpolating
    # variables.
    #
    # If the option `msg` was given as a String then it will be used. If the
    # option `msg` was given as a Symbol then it will be looked up from the
    # provider class' `msgs` declaration. If the option `msg` was not given
    # then the `cmd` string will be used.
    #
    # If the option `silence` was passed then stdout and stderr will be
    # redirected to `/dev/null`.
    #
    # If the option `python` was passed then the virtualenv with the given
    # Python version will be activated before executing the command.
    def msg
      msg = lookup(:msg, opts[:msg], str) || lookup(:cmd, str)
      msg || error(:msg, opts[:msg], str)
      msg = interpolate(msg, opts).strip
      msg = silence(msg) if silence?
      msg = python(msg) if python?
      msg
    end

    # Returns the log message for a failed command
    #
    # The message string will be interpolated, but included secrets will be
    # obfuscated. See `Dpl::Interpolate` for details on interpolating
    # variables.
    #
    # If the option `assert` was given as a String then it will be used. If the
    # option `assert` was given as a Symbol then it will be looked up from the
    # provider class' `errs` declaration. If the command was given as a Symbol,
    # and it can be found in `errs` then this String will be used.
    def err
      keys = [opts[:assert], str]
      err = lookup(:err, *keys)
      err || error(:err, *keys) if keys.any? { |key| key.is_a?(Symbol) }
      err ? interpolate(err, opts).strip : 'Failed'
    end

    # Whether or not to assert that the command has exited with 0
    #
    # Returns `true` if the option `assert` was given as `true` or not given at
    # all. Returns `false` if the option `assert` was given as `false`.
    def assert?
      !opts[:assert].is_a?(FalseClass)
    end

    # Whether or not to announce the command with an info level log message
    #
    # Returns `true` if the option `assert` was given as `true` or not given at
    # all. Returns `false` if the option `assert` was given as `false`.
    def echo?
      !opts[:echo].is_a?(FalseClass)
    end

    # Whether or not to capture the commands stdout and stderr
    #
    # Returns `true` if the option `capture` was given as `true`. Returns
    # `false` if the option `capture` was given as `false` or not given.
    def capture?
      !!opts[:capture]
    end

    # Whether or not to output a log message after the command has succeeded
    #
    # Returns `true` if the option `info` was given. Returns `false` if the
    # option `assert` was given as `false` or not given.
    def info?
      !!opts[:info]
    end

    # Returns the log message to output after the command has succeeded
    def info
      opts[:info]
    end

    # Whether or not to activate a Python virtualenv before executing the
    # command
    #
    # Returns `true` if the option `python` was given. Returns `false` if the
    # option `python` was given as `false` or not given.
    def python?
      !!opts[:python]
    end

    # Returns how often to retry the command
    def retry
      opts[:retry]
    end

    # Whether or not to redirect the command's stdout and stderr to `/dev/null`
    #
    # Returns `true` if the option `silence` was given. Returns `false` if the
    # option `silence` was given as `false` or not given.
    def silence?
      !!opts[:silence]
    end

    private

      def lookup(type, *keys)
        str = provider.send(type, *keys) if provider
        str || keys.detect { |key| key.is_a?(String) }
      end

      def error(type, *keys)
        raise("Could not find #{type}: #{keys.compact.map(&:inspect).join(', ')}")
      end

      def interpolate(str, args, opts = {})
        provider ? provider.interpolate(str, args, opts) : str
      end

      def silence(str)
        "#{str} > /dev/null 2>&1"
      end

      # Activates the Python virtualenv for the given Python version.
      def python(cmd)
        # "bash -c 'source $HOME/virtualenv/python#{opts[:python]}/bin/activate; #{cmd.gsub(/'/, "'\\\\''")}'"
        "source $HOME/virtualenv/python#{opts[:python]}/bin/activate && #{cmd}"
      end
  end
end
