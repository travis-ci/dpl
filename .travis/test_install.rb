require 'dpl'

keys = Dpl::Provider.registry.keys.sort - %i(chef_supermarket help heroku provider)
providers = keys.map { |key| Dpl::Provider[key] }

providers.each do |provider|
  opts = provider.opts.select(&:required?)
  opts = opts.map { |opt| "--#{opt.name} str" }.join(' ')
  cmd = "bin/dpl #{provider.registry_key} --stage install #{opts}"
  fail unless system cmd
end
