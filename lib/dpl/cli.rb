require 'dpl/error'
require 'dpl/provider'

module DPL
  class CLI
    def self.run(*args)
      new(args).run
    end

    OPTION_PATTERN = /\A--([a-z][a-z_\-]*)(?:=(.+))?\z/
    attr_accessor :options

    def initialize(*args)
      options = {}
      args.flatten.each do |arg|
        next options.update(arg) if arg.is_a? Hash
        die("invalid option %p" % arg) unless match = OPTION_PATTERN.match(arg)
        key = match[1].tr('-', '_').to_sym
        if options.include? key
          options[key] = Array(options[key]) << match[2]
        else
          options[key] = match[2] || true
        end
      end

      self.options = default_options.merge(options)
    end

    def run
      provider = Provider.new(self, options)
      provider.deploy
    rescue Error => error
      options[:debug] ? raise(error) : die(error.message)
    end

    def default_options
      {
        :app      => File.basename(Dir.pwd),
        :key_name => %x[hostname].strip
      }
    end

    def die(message)
      $stderr.puts(message)
      exit 1
    end
  end
end
