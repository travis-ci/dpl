# frozen_string_literal: true

# Beloved squiggly heredocs did not exist in Ruby 2.1, which we still want to
# support, so let's give kudos with a method `sq`.
module Squiggle
  # Outdents each line on a multiline string by the number of leading
  # whitespace characters on the first line.
  #
  # This method exists so we can unindet heredoc strings the same way that
  # Ruby 2.2's squiggly heredocs work, but still support Ruby 2.1 for the
  # time being.
  #
  # For example:
  #
  # str = sq(<<-str)
  #   This multiline string will be outdented by two characters,
  #     so the extra indentation on this line will be kept,
  #   while this line sits on the same level as the first line.
  # str
  def sq(str)
    width = str =~ /( *)\S/ && ::Regexp.last_match(1).size
    str.lines.map { |line| line.gsub(/^ {#{width}}/, '') }.join
  end
end
