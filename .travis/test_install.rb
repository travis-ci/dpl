require 'dpl'

def opts_for(provider)
  opts = provider.opts.select(&:required?)
  opts = opts + [provider.opts[provider.required.map(&:first).first]].compact
  opts.map { |opt| opt_for(opt) }.join(' ')
end

def opt_for(opt)
  "--#{opt.name} #{opt.enum? ? opt.enum.first : 'str'}"
end

def run(cmd)
  puts
  puts cmd
  fail unless system cmd
end

# skip = %i(help heroku provider)
# keys = Dpl::Provider.registry.keys.sort - skip
keys = [:chef_supermarket]
providers = keys.map { |key| Dpl::Provider[key] }

providers.each do |provider|
  run 'gem uninstall -aIx'
  run 'gem install cl'
  run "bin/dpl #{provider.registry_key} --stage install #{opts_for(provider)}"
  run 'gem list'
end
