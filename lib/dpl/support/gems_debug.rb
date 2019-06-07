module Gems
  module Request
    def request(method, path, data, content_type, request_host = host) # rubocop:disable AbcSize, CyclomaticComplexity, MethodLength, ParameterLists, PerceivedComplexity
      path += hash_to_query_string(data) if %i[delete get].include? method
      uri = URI.parse [request_host, path].join
      request_class = Net::HTTP.const_get method.to_s.capitalize
      request = request_class.new uri.request_uri
      request.add_field 'Authorization', key if key
      request.add_field 'Connection', 'keep-alive'
      request.add_field 'Keep-Alive', '30'
      request.add_field 'User-Agent', user_agent
      request.basic_auth username, password if username && password
      request.content_type = content_type
      case content_type
      when 'application/x-www-form-urlencoded'
        request.form_data = data if %i[post put].include? method
      when 'application/octet-stream'
        request.body = data
        request.content_length = data.size
      end
      proxy = uri.find_proxy
      @connection = if proxy
        Net::HTTP::Proxy(proxy.host, proxy.port, proxy.user, proxy.password).new(uri.host, uri.port)
      else
        Net::HTTP.new uri.host, uri.port
      end
      if uri.scheme == 'https'
        require 'net/https'
        @connection.use_ssl = true
        @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      @connection.set_debug_output $stderr
      @connection.start
      response = @connection.request request
      body_from_response(response, method, content_type)
    end
  end
end
