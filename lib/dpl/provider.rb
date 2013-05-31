require 'dpl/error'
require 'fileutils'

module DPL
  class Provider
    include FileUtils

    autoload :Heroku,     'dpl/provider/heroku'
    autoload :EngineYard, 'dpl/provider/engine_yard'
    autoload :DotCloud,   'dpl/provider/dot_cloud'

    def self.new(context, options)
      return super if self < Provider
      name = super.option(:provider).to_s.downcase.gsub(/[^a-z]/, '')
      raise Error, 'could not find provider %p' % options[:provider] unless name = constants.detect { |c| c.to_s.downcase == name }
      const_get(name).new(context, options)
    end

    def self.requires(name, version = "> 0")
      gem(name, version)
    rescue LoadError
      system("gem install %s -v %p" % [name, version])
      Gem.clear_paths
    ensure
      require name
    end

    def self.pip(name, command = name)
      system "pip install #{name}" if `which #{command}`.chop.empty?
    end

    attr_reader :context, :options

    def initialize(context, options)
      @context, @options = context, options
    end

    def option(name)
      options.fetch(name) { raise Error, "missing #{name}" }
    end

    def deploy
      rm_rf ".dpl"
      mkdir_p ".dpl"

      check_auth
      check_app

      if needs_key?
        create_key(".dpl/id_rsa")
        setup_key(".dpl/id_rsa.pub")
        setup_git_ssh(".dpl/git-ssh", ".dpl/id_rsa")
      end

      push_app

      Array(options[:run]).each do |command|
        run(command)
      end
    ensure
      remove_key if needs_key?
    end

    def needs_key?
      true
    end

    def check_app
    end

    def create_key(file)
      system "ssh-keygen -t rsa -N \"\" -C #{option(:key_name)} -f #{file}"
    end

    def setup_git_ssh(path, key_path)
      key_path = File.expand_path(key_path)
      path     = File.expand_path(path)

      File.open(path, 'w') do |file|
        file.write "#!/bin/sh\n"
        file.write "exec ssh -o StrictHostKeychecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null -i #{key_path} -- \"$@\"\n"
      end

      chmod(0740, path)
      ENV['GIT_SSH'] = path
    end

    def log(message)
      $stderr.puts(message)
    end
  end
end
