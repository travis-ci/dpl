require 'fileutils'
require 'yaml'

module Support
  module File
    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      def file(*args)
        before { file(*args) }
      end

      def dir(name)
        before { dir(name) }
      end

      def chdir(dir)
        before { @cwd = Dir.pwd; chdir(dir) }
        after  { chdir(@cwd); rm_r(dir) }
      end

      def rm(path)
        after { chdir(dir) }
      end

      def yaml(obj)
        YAML.dump(obj)
      end
    end

    def file(path, content = '')
      path = path.to_s
      FileUtils.mkdir_p(::File.dirname(path))
      ::File.open(path, 'w+') { |f| f.write(content) }
    end

    def dir(dir)
      FileUtils.mkdir_p(dir)
    end

    def chdir(name)
      dir(name)
      Dir.chdir(name)
    end

    def rm_r(*paths)
      paths.each { |path| FileUtils.rm_r(path) }
    end
    alias rm rm_r

    def rm_rf(*paths)
      paths.each { |path| FileUtils.rm_rf(path) }
    end

    def yaml(obj)
      YAML.dump(obj)
    end
  end
end
