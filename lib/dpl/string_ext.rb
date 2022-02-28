class String
  def whitelist
    @is_whitelisted = true
  end

  def whitelisted?
    @is_whitelisted
  end

  def blacklist
    @is_whitelisted = false
  end

  def blacklisted?
    !@is_whitelisted
  end
end