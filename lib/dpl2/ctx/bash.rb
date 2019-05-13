require 'cl'
require 'logger'
require 'tmpdir'
require 'rendezvous'
require 'dpl2/ctx/script'

module Dpl
  module Ctx
    class Test < Cl::Ctx
      def initialize
        super('dpl')
      end

      def exists?(path)
        File.exists?(path)
      end

      def fold(name)
        yield # TODO
      end

      def apt_get(name, cmd)
        shell "sudo apt-get -qq install #{name}", retry: true) unless which(cmd)
      end

      def npm_install(name, cmd = name)
        shell "npm install -g #{name}", retry: true unless which(cmd)
      end

      def pip_install(name, cmd = name, version = nil)
        shell "pip uninstall --user -y #{name}" if version && which(cmd) # why only if version was given?
        cmd = "pip install --user #{name}"
        cmd << "==#{version}" if version
        shell cmd, echo: true, retry: true
        shell 'export PATH=$PATH:$HOME/.local/bin'
      end

      def npm_version
        `npm --version`
      end

      def script(name, opts = {})
        shell Script.new(registry_key, name).read, opts
      end

      # TODO retry
      def shell(cmd, opts = {})
        cmd = "#{cmd} > /dev/null 2>&1" if opts[:silence]
        cmd = with_python(cmd, opts[:python]) if opts[:python]

        info cmd if opts[:echo]
        out, err, status = Open3.capture3(cmd, only(opts, :chdir))

        args = { status: status, out: out, err: err }
        info opts[:info] % args if opts[:info] && success?
        error opts[:assert] % args if opts[:assert] && !success?

        @last_status = status
      end

      def with_python(cmd, verion)
        "bash -c 'source $HOME/virtualenv/python#{version}/bin/activate; #{cmd.gsub(/'/, "'\\\\''")}'"
      end

      def success?
        !!@last_status
      end

      def experimental(name)
        info "\n!!! #{name} support is experimental !!!\n\n"
      end

      def deprecated(*lines)
        warn "\n#{lines.join("\n")}\n\n"
      end

      def info(*msgs)
        $stdout.puts(*msgs)
      end

      def print(chars)
        $stdout.print(chars)
      end

      def warn(*msgs)
        msgs = msgs.join("\n").lines
        msgs.each { |msg| $stderr.puts(red(msg)) }
      end

      def error(message)
        raise Error, message
      end

      def red(str)
        "\e[31;1m#{str}\e[0m"
      end

      def deprecate_opt(key, msg)
        msg = "please use #{msg}" if msg.is_a?(Symbol)
        warn("deprecated option #{key} (#{msg})")
      end

      def repo_name
        File.basename(Dir.pwd)
      end

      def repo_slug
        ENV['TRAVIS_REPO_SLUG']
      end

      def build_dir
        ENV['TRAVIS_BUILD_DIR'] || '.'
      end

      def build_number
        ENV['TRAVIS_BUILD_NUMBER']
      end

      def git_tag
        `git describe --tags --exact-match 2>/dev/null`.chomp
      end

      def remotes
        `git remote -v`.scan(/\t[^\s]+\s/).map(&:strip).uniq
      end

      def git_log(args)
        `git log #{args}`
      end

      def git_rev_parse(ref)
        `git rev-parse #{ref}`.strip
      end

      def sha
        ENV['TRAVIS_COMMIT'] || `git rev-parse HEAD`.strip
      end

      def commit_msg
        `git log #{sha} -n 1 --pretty=%B`.strip
      end

      def files
        `git ls-files -z`.split("\x0")
      end

      def which(cmd)
        !`which #{cmd}`.chop.empty?
      end

      def machine_name
        `hostname`.strip
      end

      def tmpdir
        Dir.mktmpdir
      end

      def ssh_keygen(name, file)
        shell %(ssh-keygen -t rsa -N "" -C #{name} -f #{file})
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

      def logger(level = :info)
        logger = Logger.new($stderr)
        logger.level = Logger.const_get(level.to_s.upcase)
        logger
      end

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
