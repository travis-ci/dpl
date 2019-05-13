module Dpl
  module Ctx
    # Rather than reading these and running them through Ruby's system() ...
    # can we not install them as executables using the gemspec, and then only
    # call shell('provider/name.sh') or something?
    class Script < Struct.new(:provider, :name)
      DIR = File.expand_path('../../scripts', __FILE__)

      def read
        exists? ? File.read(path) : unknown
      end

      def exists?
        File.exists?(path)
      end

      def unknown
        raise "Could not find script #{path}."
      end

      def path
        "#{DIR}/#{provider}/#{name}.sh"
      end
    end
  end
end
