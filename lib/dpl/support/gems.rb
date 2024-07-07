# frozen_string_literal: true

require 'ripper'

module Dpl
  module Support
    class Gems < Struct.new(:glob, :opts)
      def each(&block)
        all.uniq.each(&block)
      end

      def all
        Dir[glob].sort.inject([]) do |gems, path|
          next gems if except.any? { |str| path.include?(str) }

          gems + Parse.new(File.read(path)).gems
        end
      end

      def except
        @except ||= Array(opts[:except]).map(&:to_s)
      end

      def opts
        super || {}
      end

      class Parse < Struct.new(:code)
        def gems
          return [] unless sexp
          walk(*sexp).flatten.each_slice(3).to_a
        end

        def walk(key, *nodes)
          case key
          when :program
            nodes[0].map { |node| walk(*node) }.compact
          when :module
            walk(*nodes[1])
          when :class
            walk(*nodes[2])
          when :bodystmt
            nodes[0].map { |node| walk(*node) }.compact
          when :command
            walk(*nodes[1]) if nodes[0][1] == 'gem'
          when :args_add_block
            args = nodes[0].map { |node| walk(*node) }
            opts = args.last.is_a?(Hash) ? args.pop : {}
            name, version = *args
            [name, version, opts]
          when :bare_assoc_hash
            walk(*nodes[0][0])
          when :assoc_new
            [nodes.map { |node| walk(*node) }].to_h
          when :@label
            nodes.first.sub(':', '').to_sym
          when :string_literal
            walk(*nodes[0])
          when :string_content
            nodes[0][1]
            # when :void_stmt
            # else
            #   raise key.to_s
          end
        end

        def sexp
          Ripper.sexp(code)
        end
      end
    end
  end
end
