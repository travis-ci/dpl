require 'dpl'

passing = %i(
  anynines
  atlas
  azure_web_apps
  bit_balloon
  bluemix_cloud_foundry
  boxfuse
  cargo
  catalyze
  cloud66
  cloud_files
  cloud_foundry
  code_deploy
  deis
  elastic_beanstalk
  engine_yard
  firebase
  gae
  gcs
  hephy
  lambda
  launchpad
  npm
  open_shift
  ops_works
  packagecloud
  pages
  puppet_forge
  releases
  rubygems
  s3
  scalingo
  script
)

skip = %i(chef_supermarket help heroku heroku:api heroku:git provider)
keys = Dpl::Provider.registry.keys.sort - skip - passing
providers = keys.map { |key| Dpl::Provider[key] }

def opt_for(opt)
  "--#{opt.name} #{opt.enum? ? opt.enum.first : 'str'}"
end

providers.each do |provider|
  opts = provider.opts.select(&:required?)
  opts = opts + [provider.opts[provider.required.map(&:first).first]].compact
  opts = opts.map { |opt| opt_for(opt) }.join(' ')
  cmd = "bin/dpl #{provider.registry_key} --stage install #{opts}"
  puts cmd
  fail unless system cmd
end
