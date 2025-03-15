require "yaml"
require "pathname"
require 'digest'
require_relative "shell/ripgrep"

module Snip
  class Paper
    KEYWORD = "SNIP:"

    attr_accessor :path
    attr_accessor :meta
    attr_accessor :digest

    def parse_block_commet(content, kw_index)
      block_patterns = [
        [ "/*", "*/" ],
        [ "<!--", "-->" ],
        [ "=begin", "=end" ],
      ]

      block_pattern = block_patterns.detect do |(prefix, suffix)|
        content.rindex(prefix, kw_index - 1)
      end
      return nil if block_pattern.nil?

      kw_line_no = content[0..kw_index].lines.size - 1
      kw_line_index = content.lines[0...kw_line_no].join.size
      text_start_index = content.rindex(block_pattern[0], kw_index - 1) + block_pattern[0].length

      if text_start_index < kw_line_index
        prefix = content[kw_line_index...kw_index]
      else
        prefix = content[text_start_index...kw_index]
      end

      text_end_index = content.index(block_pattern[1], text_start_index) - 1
      markdown = content[text_start_index..text_end_index].lines.each_with_object("") do |line, acc|
        if line.start_with?(prefix)
          acc << line[prefix.length..]
        elsif line.strip.empty?
          # skip
        else
          acc << line
        end
      end

      YAML.load(markdown) rescue nil
    end

    def parse_prefix_commet(content, kw_index)
      kw_line_no = content[0..kw_index].lines.count - 1
      prefix = content[0...kw_index].lines.last

      markdown = content.lines[kw_line_no..].each_with_object("") do |line, acc|
        if line.start_with?(prefix)
          acc << line[prefix.length..]
        elsif line.strip.empty?
          # skip
        else
          break acc
        end
      end

      YAML.load(markdown) rescue nil
    end

    def gist_repo
      @gist_repo ||= (meta["SNIP"] || "").split("|").map(&:strip)[0]
    end

    def file_alias
      return @file_alias if defined?(@file_alias)
      @file_alias = (meta["SNIP"] || "").split("|").map(&:strip)[1]
    end

    def filename
      file_alias || File.basename(self.path)
    end

    def changelogs
      meta["CHANGELOG"] || []
    end

    def valid?
      !!self.meta
    end
  end
end
