require 'fakefs/safe'
require 'fileutils'

module Support
  module FakeFs
    def self.included(base)
      base.let(:build_dir) { '/home/travis/build/travis-ci/dpl' }

      paths = %w(
        ../../../lib/dpl/assets
        ../../../spec/fixtures
      )

      base.before do
        ::FakeFS.activate!

        paths.each do |path|
          path = ::File.expand_path(path, __FILE__)
          ::FakeFS::FileSystem.clone(path)
        end

        dir ::File.expand_path('~')
        chdir build_dir
      end

      base.after do
        ::FakeFS.deactivate!
      end
    end
  end
end
