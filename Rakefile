require 'bundler'

task(:default) { ruby '-S rspec' }

desc "Test provider"
task :test_provider, [:provider] do |t, args|
  provider = args.provider

  Bundler.setup(provider.to_sym)

  `bundle exec rspec spec/provider/#{provider}_spec.rb`
end