# frozen_string_literal: true

RSpec::Matchers.define :have_logged do |line|
  match do
    ctx.stderr.string.include?(line)
  end
end
