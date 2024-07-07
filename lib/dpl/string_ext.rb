# frozen_string_literal: true

class String
  def whitelist
    @is_whitelisted = true

    self
  end

  def whitelisted?
    @is_whitelisted
  end

  def blacklist
    @is_whitelisted = false

    self
  end

  def blacklisted?
    @is_whitelisted.nil? ? false : !@is_whitelisted
  end
end
