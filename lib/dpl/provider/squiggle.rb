module Squiggle
  # Beloved squiggly heredocs did not existin Ruby 2.1.0, which we still
  # want to support, so let's give kudos with this method in the meantime.
  def sq(str)
    width = str =~ /( *)\S/ && $1.size
    str.lines.map { |line| line.gsub(/^ {#{width}}/, '') }.join
  end
end
