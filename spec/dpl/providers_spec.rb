describe Dpl::Providers do
  let(:gems) { Support::Gemfile.gems.to_h }

  skip = %i(bit_balloon chef_supermarket help heroku provider)
  keys = Dpl::Provider.registry.keys.sort - skip
  providers = keys.map { |key| Dpl::Provider[key] }

  matcher :match_gemfile do
    match do |(name, version, _)|
      @name, @version = name, version
      expect(gems[name]).to eq version
    end

    failure_message do
      "Expected the #{@name}'s version #{@version} to match the Gemfile, but it does not. Instead the Gemfile specifies: #{gems[@name] || "nothing for this #{@name}"}."
    end
  end

  providers.map do |provider|
    provider.gem.each do |gem|
      it provider.registry_key.to_s do
        expect(gem).to match_gemfile
      end
    end
  end
end
