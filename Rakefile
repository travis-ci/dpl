require 'bundler'
require 'term/ansicolor'
require 'pathname'
require 'logger'
require './lib/dpl/version'

include Term::ANSIColor

def logger
  @logger ||= Logger.new($stdout)
end

def top
  @top ||= Pathname.new File.expand_path(File.dirname(__FILE__))
end

def gem_version
  ENV['DPL_VERSION'] || DPL::VERSION
end

gemspecs = FileList[File.join(top, "dpl-*.gemspec")]

providers = gemspecs.map { |f| /dpl-(?<provider>.*)\.gemspec/ =~ f && provider }

dpl_bin = File.join(Gem.bindir, "dpl")

task :default => [:spec, :install] do
  Rake::Task["spec_providers"].invoke
  Rake::Task["check_providers"].invoke
end

task :spec_providers do
  providers.each do |provider|
    Rake::Task["spec-#{provider}"].invoke
  end
end

task :check_providers do
  providers.each do |provider|
    Rake::Task["check-#{provider}"].invoke
  end
end

task :deep_clean do
  Rake::Task[:clean].invoke
  sh "git clean -dfx"
end

task :clean do
  rm_rf "stubs"
  rm_rf "vendor"
end

desc "Run dpl specs"
task :spec do
  ruby '-S rspec spec/cli_spec.rb spec/provider_spec.rb'
end

desc "Build dpl gem"
file "dpl-#{gem_version}.gem" do
  logger.info green("Building dpl gem")
  ruby "-S gem build dpl.gemspec"
end

desc "Install dpl gem"
task :install => "dpl-#{gem_version}.gem" do
  Rake::FileTask[dpl_bin].invoke
end

file dpl_bin do
  logger.info green("Installing dpl gem")
  ruby "-S gem install dpl-#{gem_version}.gem"
end

providers.each do |provider|
  desc "Write Gemfile-#{provider}"
  file "Gemfile-#{provider}" do |t|
    gemfile = top + t.name
    logger.info green("Writing #{gemfile}")
    gemfile.write %Q(source 'https://rubygems.org'\ngemspec :name => "dpl-#{provider}"\n)
  end

  desc %Q(Run dpl-#{provider} specs)
  task "spec-#{provider}" => [:install, "Gemfile-#{provider}"] do |t|
    logger.info green("Running `bundle install` for #{provider}")
    # rm_rf 'stubs'
    # rm_rf '.bundle'
    sh 'bash', '-cl', "bundle install --gemfile=Gemfile-#{provider} --verbose --retry=3 --binstubs=stubs"
    logger.info green("Running specs for #{provider}")
    sh "env BUNDLE_GEMFILE=Gemfile-#{provider} ./stubs/rspec spec/provider/#{provider}_spec.rb"
  end

  desc "Build dpl-#{provider} gem"
  file "dpl-#{provider}-#{gem_version}.gem" do
    logger.info green("Building dpl-#{provider} gem")
    ruby "-S gem build --silent dpl-#{provider}.gemspec"
  end

  desc "Test dpl-#{provider} gem"
  task "check-#{provider}" => [:install, "dpl-#{provider}-#{gem_version}.gem"] do
    logger.info green("Installing dpl-#{provider} gem")
    sh "gem install --no-post-install-message dpl-#{provider}-#{gem_version}.gem"
    logger.info green("Testing dpl-#{provider} loads correctly")
    ruby "-S dpl --provider=#{provider} --skip-cleanup=true --no-deploy"
  end

end

