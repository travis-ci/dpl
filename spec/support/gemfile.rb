require 'ripper'

module Support
  module Gemfile
    extend self

    def gems
      code = ::File.read(::File.expand_path('../../../Gemfile', __FILE__))
      sexp = Ripper.sexp(code)
      walk(*sexp)
    end

    def walk(key, *nodes)
      case key
      when :program
        nodes[0].map { |node| walk(*node) }.compact
      when :command
        walk(*nodes[1]) if nodes[0][1] == 'gem'
      when :args_add_block
        nodes[0].map { |node| walk(*node) }
      when :string_literal
        walk(*nodes[0])
      when :string_content
        nodes[0][1]
      end
    end
  end
end
