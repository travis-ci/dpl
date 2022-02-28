class String
  def whitelist
    @flag = true
  end

  def whitelisted?
    !@flag
  end

  def blacklist
    @flag = false
  end

  def blacklisted?
    @flag
  end
end