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

task :default => [:spec, :install] do
  providers.each do |provider|
    Rake::Task["spec-#{provider}"].invoke
  end
  providers.each do |provider|
    Rake::Task["test-dpl-#{provider}"].invoke
  end
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
  logger.info green("Installing dpl gem")
  ruby "-S gem install dpl-#{gem_version}.gem"
end

providers.each do |provider|
  desc "Write Gemfile-#{provider}"
  file "Gemfile-#{provider}" do |t|
    dest = top + t.name
    logger.info green("Writing #{dest}")
    dest.write %Q(source 'https://rubygems.org'\ngemspec :name => "dpl-#{provider}"\n)
  end

  desc %Q(Run dpl-#{provider} specs)
  task "spec-#{provider}" => "Gemfile-#{provider}" do |t|
    logger.info green("Running `bundle install` for #{provider}")
    sh "env BUNDLE_GEMFILE=Gemfile-#{provider} bundle install --gemfile=Gemfile-#{provider} --path=vendor/cache/dpl-#{provider} --binstubs=bin && ./bin/rspec spec/provider/#{provider}_spec.rb"
  end

  desc "Build dpl-#{provider} gem"
  file "dpl-#{provider}-#{gem_version}.gem" do
    logger.info green("Building dpl-#{provider} gem")
    ruby "-S gem build --silent dpl-#{provider}.gemspec"
  end

  desc "Test dpl-#{provider} gem"
  task "test-dpl-#{provider}" => "dpl-#{provider}-#{gem_version}.gem" do
    logger.info green("Installing dpl-#{provider} gem")
    ruby "-S gem install --no-post-install-message dpl-#{provider}-#{gem_version}.gem"
    logger.info green("Testing dpl-#{provider} loads correctly")
    ruby "-S dpl --provider=#{provider} --skip-cleanup=true --no-delploy"
  end

end

