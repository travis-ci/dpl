require 'cl'
require 'dpl2/ctx/script'

module Dpl
  module Ctx
    class Test < Cl::Ctx
      def initialize
        super('dpl')
      end

      def fold(name)
      end

      def script(name)
        shell Script.new(registry_key, name).read
      end

      def shell(cmd, opts = {})
        cmd = "#{cmd} > /dev/null 2>&1" if opts[:silence]
        @last_result = system(cmd, only(opts, :chdir))
        error opts[:assert] if opts[:assert] && !success?
      end

      def success?
        !!@last_result
      end

      def info(msg)
        $stdout.puts(msg)
      end

      def warn(msg)
        $stderr.puts("\e[31;1m#{msg}\e[0m")
      end

      def error(message)
        raise Error, message
      end

      def deprecate_opt(old, new)
        warn("deprecated option #{old}, please use: #{new}")
      end

      def only(hash, *keys)
        hash.select { |key, _| keys.include?(key) }.to_h
      end
    end
  end
end
