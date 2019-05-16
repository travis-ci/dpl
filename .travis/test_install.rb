require 'dpl'

keys = Dpl::Provider.registry.keys.sort - %i(chef_supermarket help heroku provider)
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
