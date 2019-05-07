RSpec::Matchers.define :have_netrc do |host, opts|
  match do
    Netrc.configure { |config| config[:allow_permissive_netrc_file] = true }
    entry = Netrc.read[host]
    opts.each { |key, value| expect(entry[key]).to eq value }
  end
end
