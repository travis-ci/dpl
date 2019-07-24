require 'cl'
require 'stringio'
require 'dpl/helper/squiggle'

module Dpl
  module Ctx
    class Test < Cl::Ctx
      include Squiggle

      attr_reader :cmds, :stderr, :last_out, :last_err

      def initialize
        @cmds = []
        @stderr = StringIO.new
        super('dpl')
      end

      def fold(name)
        cmds << "[fold] #{name}"
        yield.tap { cmds << "[unfold] #{name}" }
      end

      def validate_runtimes(runtimes)
        runtimes.each do |name, requirements|
          cmds << "[validate:runtime] #{name} (#{requirements.join(', ')})"
        end
      end

      def apts_get(apts)
        apts.each { |apt| apt_get(*apt) }
      end

      def apt_get(name, cmd = name)
        cmds << "[apt:get] #{name} (#{cmd})"
      end

      def gems_require(gems)
        gems.each { |gem| gem_require(gem) }
      end

      def gem_require(name, version = nil, opts = {})
        cmds << "[gem:require] #{name} (#{version}, #{opts})"
      end

      def npm_install(name, cmd = name)
        cmds << "[npm:install] #{name} (#{cmd})"
      end

      def pip_install(name, cmd = name, version = nil)
        cmds << "[pip:install] #{name} (#{cmd}, #{version})"
      end

      def ssh_keygen(name, file)
        File.open(file, 'w+') { |f| f.write('private-key') }
        File.open("#{file}.pub", 'w+') { |f| f.write('ssh-rsa public-key') }
      end

      def shell(cmd, opts = {})
        cmd = with_silence(cmd, opts)
        cmd = "[python:#{opts[:python]}] #{cmd}" if opts[:python]
        msg = opts[:msg] ? with_silence(opts[:msg], opts) : cmd
        info "$ #{msg}" unless opts[:echo].is_a?(FalseClass)
        cmds << cmd
      end

      def with_silence(str, opts)
        opts[:silence] ? "#{str} > /dev/null 2>&1" : str
      end

      def success?
        true
      end

      def info(msg)
        cmds << "[info] #{msg}"
      end

      def print(chars)
        cmds << "[print] #{chars}"
      end

      def warn(msg)
        cmds << "[warn] #{msg}"
      end

      def error(message)
        raise Error, message
      end

      def deprecate_opt(key, msg)
        msg = "please use #{msg}" if msg.is_a?(Symbol)
        warn("deprecated option #{key} (#{msg})")
      end

      def repo_name
        'dpl'
      end

      def repo_slug
        'travis-ci/dpl'
      end

      def build_dir
        '.'
      end

      def build_number
        1
      end

      def git_commit_msg
        'commit msg'
      end

      def git_log(args)
        'commits'
      end

      def git_ls_files
        %w(one two)
      end

      def git_remote_urls
        ['git://origin.git']
      end

      def git_rev_parse(ref)
        "ref: #{ref}"
      end

      def git_tag
        'tag'
      end

      def git_sha
        'sha'
      end

      def machine_name
        'machine_name'
      end

      def node_version
        '11.0.0'
      end

      def npm_version
        '1'
      end

      def which(cmd)
        false
      end

      def tmp_dir
        FileUtils.mkdir_p('tmp')
        'tmp'
      end

      def sleep(*)
      end

      def encoding(path)
        'text'
      end

      def logger(level = :info)
        logger = Logger.new(stderr)
        logger.level = Logger.const_get(level.to_s.upcase)
        logger
      end

      def test?
        true
      end

      def file_size(path)
        File.size(path.sub("#{File.expand_path('~')}", './home'))
      end

      def move_files(paths)
        paths.each do |path|
          mv(path, "/tmp/#{File.basename(path)}")
        end
      end

      def unmove_files(paths)
        paths.each do |path|
          mv("/tmp/#{File.basename(path)}", path)
        end
      end

      def mv(src, dest)
        cmds << [:mv, src, dest].join(' ')
      end

      def write_file(path, content, chmod = nil)
        path = File.expand_path(path)
        path = path.sub("#{File.expand_path('~')}", './home')
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, 'w+') { |f| f.write(content) }
      end

      def write_netrc(machine, login, password)
        write_file('~/.netrc', sq(<<-rc))
          machine #{machine}
            login #{login}
            password #{password}
        rc
      end

      def tty?
        false
      end

      def except(hash, *keys)
        hash.reject { |key, _| keys.include?(key) }
      end
    end
  end
end
