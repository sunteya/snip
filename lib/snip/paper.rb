require "yaml"
require "pathname"

module Snip
  class Paper
    attr_accessor :path
    attr_accessor :meta

    def initialize(path)
      self.path = path
      self.parse
    end

    def parse
      lines = File.read(path).lines

      [ "#",  # Ruby
        "//", # C
        "--", # SQL
        "*",  # CSS?
        " ",  # HTML?
      ].each do |commet_keyword|
        if (meta = parse_by_commet(lines, commet_keyword))
          self.meta = meta
          return
        end
      end
    end

    def parse_by_commet(lines, commet_keyword)
      commet_prefix = %r/^\s*#{Regexp.escape(commet_keyword)}/
      snip_regexp = /(#{commet_prefix}\s*)SNIP:(.*)$/
      snip_index = lines.index { |line| line.match?(snip_regexp) }
      return false if !snip_index
      # start_pos = lines[0, snip_index].rindex { |line| !line.match?(commet_prefix) } || (snip_index - 1) + 1
      start_pos = snip_index
      stop_pos = snip_index + lines[snip_index, lines.length].index { |line| !line.match?(commet_prefix) } - 1

      snip_lines = lines[start_pos..stop_pos]
      prefix_length = lines[snip_index].match(snip_regexp)[1].length
      snip_content = snip_lines.map { |line| line.slice(prefix_length, line.length) }.join
      YAML.load(snip_content)
    end

    def gist_repo
      @gist_repo ||= meta["SNIP"].split("|").map(&:strip)[0]
    end

    def gist_file_pattern
      @gist_file_pattern ||= meta["SNIP"].split("|").map(&:strip)[1]
    end

    def changelogs
      meta["CHANGELOG"] || []
    end

    def files
      return @files_mapping if defined?(@files_mapping)
      root = Pathname.pwd
      dir = Pathname.new(path).dirname

      @files_mapping = {}
      @files_mapping[Pathname.new(path).expand_path.relative_path_from(root)] = gist_file_pattern

      [ meta["FILES"] ].flatten.compact.each do |file_pattern|
        pattern, target = file_pattern.split("=>")
        paths = Pathname.glob(File.expand_path("./**", dir))

        if target && paths.any?
          @files_mapping[paths.first.expand_path.relative_path_from(root)] = target.strip
        else
          paths.each { |path| @files_mapping[path.expand_path.relative_path_from(root)] ||= nil }
        end
      end

      @files_mapping
    end

    def valid?
      self.meta && self.meta.any?
    end

    def self.scan
      paths = `rg -l SNIP:`.lines
      paths.map do |path|
        paper = Paper.new(path.chomp)
        paper if paper.valid?
      end.compact.sort_by { |paper| [ paper.gist_repo, paper.path ] }
    end
  end
end
