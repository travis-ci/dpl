module DPL
  class Provider
    class BluemixCloudFoundry < CloudFoundry

      REGIONS = Hash.new {"api.ng.bluemix.net"}.update(
        "eu-gb" => "api.eu-gb.bluemix.net",
        "eu-de" => "api.eu-de.bluemix.net",
        "au-syd" => "api.au-syd.bluemix.net"
      )

      def set_api
        region = options[:region] || "ng"
        options[:api] = options[:api] || REGIONS[region]
      end

      def check_auth
        set_api
        super
      end

    end
  end
end
