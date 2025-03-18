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
    #   remote_name: "file.txt",
    #   local_name: "file.txt",
    #   path: "path/to/file.txt",
    # }
    def file_infos
      return @file_infos if defined?(@file_infos)

      dir = Pathname.new(path).dirname

      file_infos = (meta["FILES"] || []).flat_map do |line|
        pattern, alias_name = line.split("=>").map(&:strip)
        paths = dir.glob(pattern)
        paths.map do |path|
          {
            remote_name: alias_name || path.basename.to_s,
            local_name: path.basename.to_s,
            path: path.to_s,
          }
        end
      end
      file_infos = file_infos.delete_if { |info| Pathname.new(info[:path]).realpath == Pathname.new(path).realpath }
      file_infos
    end

    def self.scan
      paths = Shell::Ripgrep.search_snip
      paths.map do |path|
        paper = LocalPaper.new(path)
        paper.parse
        paper if paper.valid?
      end.compact.sort_by(&:path)
    end
  end
end