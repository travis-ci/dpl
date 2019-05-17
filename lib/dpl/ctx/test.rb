require 'cl'
require 'stringio'
require 'dpl/helper/squiggle'

module Dpl
  module Ctx
    class Test < Cl::Ctx
      include Squiggle

      attr_reader :cmds, :stderr

      def initialize
        @cmds = []
        @stderr = StringIO.new
        super('dpl')
      end

      def fold(name)
        cmds << "[fold] #{name}"
        yield.tap { cmds << "[unfold] #{name}" }
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
        cmd = "#{cmd} > /dev/null 2>&1" if opts[:silence]
        cmd = "[python:#{opts[:python]}] #{cmd}" if opts[:python]
        cmds << cmd
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

      def write_file(path, content)
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

      def except(hash, *keys)
        hash.reject { |key, _| keys.include?(key) }
      end
    end
  end
end
