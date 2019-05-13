require 'memfs'
require 'fileutils'

module Support
  module MemFs
    def self.included(base)
      base.let(:build_dir) { '/home/travis/build/travis-ci/dpl' }
      base.before { ::MemFs.activate! }
      base.before { dir ::File.expand_path('~') }
      base.before { chdir(build_dir) }
      base.after  { ::MemFs.deactivate! }
    end
  end
end
