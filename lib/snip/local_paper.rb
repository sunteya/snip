require_relative "paper"

module Snip
  class LocalPaper < Paper
    def initialize(path)
      self.path = path
    end

    def parse
      content = File.read(path)
      index = content.index(KEYWORD)
      return if index.nil?

      self.digest = Digest::MD5.hexdigest(content)
      self.meta = nil
      self.meta ||= parse_block_commet(content, index)
      self.meta ||= parse_prefix_commet(content, index)
    end

    # file_info = {
    #   filename: "file.txt",
    #   path: "path/to/file.txt",
    # }
    def file_infos
      return @file_infos if defined?(@file_infos)

      dir = Pathname.new(path).dirname

      files = (meta["FILES"] || []).flat_map do |pattern|
        dir.glob(pattern)
      end
      files.delete_if { |file| file.realpath == Pathname.new(path).realpath }

      @file_infos = files.map do |file|
        {
          filename: file.basename.to_s,
          path: file.to_s,
        }
      end
    end

    def self.scan
      paths = Shell::Ripgrep.search_snip
      paths.map do |path|
        paper = LocalPaper.new(path)
        paper.parse
        paper if paper.valid?
      end.compact.sort_by { |paper| [ paper.gist_repo, paper.path ] }
    end
  end
end