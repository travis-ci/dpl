GStore::Client.class_eval do
  def sign(str)
    digest = OpenSSL::Digest.new('sha1') # use undeprecated constant
    b64_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, @secret_key, str)).gsub("\n","")
  end
end
