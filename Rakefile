require 'bundler'
require 'term/ansicolor'
require 'pathname'
require 'logger'
require './lib/dpl/version'
require 'highline'
require 'faraday'

include Term::ANSIColor

def cli
  @cli ||= HighLine.new
end

@ready = false

def logger
  @logger ||= Logger.new($stdout)
end

def top
  @top ||= Pathname.new File.expand_path(File.dirname(__FILE__))
end

def gem_version
  ENV['DPL_VERSION'] || DPL::VERSION
end

def confirm(verb = "release")
  unless @ready
    answer = cli.ask "Ready to #{verb} `dpl` version #{gem_version}? (y/n)"
    if answer !~ /^y/i
      abort red("Aborting #{verb}")
    end

    @ready = true
  end
end

def dpl_bin
  File.join(Gem.bindir, 'dpl')
end

gemspecs = FileList[File.join(top, "dpl-*.gemspec")]

providers = gemspecs.map { |f| /dpl-(?<provider>.*)\.gemspec/ =~ f && provider }

desc "Build dpl gem"
file "dpl-#{gem_version}.gem" do
  logger.info green("Building dpl gem")
  ruby "-S gem build dpl.gemspec"
end

desc "Install dpl gem"
file dpl_bin => "dpl-#{gem_version}.gem" do
  logger.info green("Installing dpl gem")
  ruby "-S gem install dpl-#{gem_version}.gem"
end

task :default => [:spec, Rake::FileTask[dpl_bin]] do
  Rake::Task["spec_providers"].invoke
  Rake::Task["check_providers"].invoke
end

desc "Run spec on all providers"
task :spec_providers do
  providers.each do |provider|
    Rake::Task["spec-#{provider}"].invoke
  end
end

desc "Check all provider gems install correctly"
task :check_providers do
  providers.each do |provider|
    Rake::Task["check-#{provider}"].invoke
  end
end

desc "Build all gems"
task :build => "dpl-#{gem_version}.gem" do
  providers.each do |provider|
    Rake::Task["dpl-#{provider}-#{gem_version}.gem"].invoke
  end
end

desc "Uninstall all gems"
task :uninstall do
  providers.each do |provider|
    Rake::Task["uninstall-#{provider}"].invoke
  end
  logger.info red("Uninstalling dpl")
  sh "gem uninstall -aIx dpl"
end

desc "Release all gems"
task :release do
  confirm
  released = []
  providers.each do |provider|
    while !released.include? provider
      logger.info "checking dpl-#{provider}"

      cli = Faraday.new url: 'https://rubygems.org'

      begin
        response = cli.get("/api/v2/rubygems/dpl-#{provider}/versions/#{gem_version}.json")
        if response.success?
          released << provider
          logger.info green("dpl-#{provider} #{gem_version} exists")
          next
        else
          begin
            if Rake::Task["release-#{provider}"].invoke
              released << provider
            end
          rescue => e
            Rake::Task["release-#{provider}"].reenable
          end
        end
      rescue Faraday::Error => e
        logger.info yellow("connection failed. retrying")
        retry
      end
    end
  end
  logger.info green("Pushing dpl-#{gem_version}.gem")
  sh "gem push dpl-#{gem_version}.gem"
end

desc "Yank all gems"
task :yank, [:version] do |t, args|
  version = args.version
  confirm "yank"
  logger.info green("Yanking `dpl` version #{version}")
  sh "gem yank dpl -v #{version}"
  providers.each do |provider|
    Rake::Task["yank-#{provider}"].invoke
  end
end

task :deep_clean do
  Rake::Task[:clean].invoke
  sh "git clean -dfx"
end

task :clean do
  rm_rf "stubs"
  rm_rf "vendor"
  rm_rf "dpl-*.gem"
  Rake::Task[:uninstall].invoke
end

desc "Run dpl specs"
task :spec do
  ruby '-S rspec spec/cli_spec.rb spec/provider_spec.rb'
end

providers.each do |provider|
  desc "Write Gemfile-#{provider}"
  file "Gemfile-#{provider}" do |t|
    gemfile = top + t.name
    logger.info green("Writing #{gemfile}")
    gemfile.write %Q(source 'https://rubygems.org'\ngemspec :name => "dpl-#{provider}"\n)
  end

  desc %Q(Run dpl-#{provider} specs)
  task "spec-#{provider}", [:lines] => [Rake::FileTask[dpl_bin], "Gemfile-#{provider}"] do |_t, args|
    tail = args.lines ? ":#{args.lines}" : ""
    sh "rm -f $HOME/.npmrc"
    logger.info green("Running `bundle install` for #{provider}")
    sh 'bash', '-cl', "bundle install --gemfile=Gemfile-#{provider} --path=vendor/cache/dpl-#{provider} --retry=3 --binstubs=stubs"
    logger.info green("Running specs for #{provider}")
    sh "env BUNDLE_GEMFILE=Gemfile-#{provider} ./stubs/rspec spec/provider/#{provider}_spec.rb#{tail}"
  end

  desc "Build dpl-#{provider} gem"
  file "dpl-#{provider}-#{gem_version}.gem" do
    logger.info green("Building dpl-#{provider} gem")
    ruby "-S gem build --silent dpl-#{provider}.gemspec"
  end

  desc "Test dpl-#{provider} gem"
  task "check-#{provider}" => [Rake::FileTask[dpl_bin], "dpl-#{provider}-#{gem_version}.gem"] do
    logger.info green("Installing dpl-#{provider} gem")
    sh "gem install --no-post-install-message dpl-#{provider}-#{gem_version}.gem"
    logger.info green("Testing dpl-#{provider} loads correctly")
    ruby "-S dpl --provider=#{provider} --skip-cleanup=true --no-deploy"
  end

  desc "Uninstall dpl-#{provider}"
  task "uninstall-#{provider}" do
    logger.info red("Uninstalling dpl-#{provider}")
    sh "gem uninstall -aIx dpl-#{provider}"
  end

  desc "Release dpl-#{provider} gem"
  task "release-#{provider}" => "dpl-#{provider}-#{gem_version}.gem" do
    confirm
    logger.info green("Pushing dpl-#{provider}-#{gem_version}.gem")
    sh "gem push dpl-#{provider}-#{gem_version}.gem"
  end

  desc "Yank dpl-#{provider}"
  task "yank-#{provider}" do
    logger.info green("Yanking dpl-#{provider} version #{gem_version}")
    sh "gem yank dpl-#{provider} -v #{gem_version}"
  end
end
