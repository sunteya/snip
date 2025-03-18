require_relative "paper"

module Snip
  class RemotePaper < Paper
    attr_accessor :gist
    attr_accessor :attrs

    def initialize(attrs, gist)
      self.attrs = attrs
      self.gist = gist
      self.path = attrs["filename"]
    end

    def parse
      index = content.index(KEYWORD)
      return if index.nil?

      self.digest = Digest::MD5.hexdigest(content)
      self.meta = nil
      self.meta ||= parse_block_commet(content, index)
      self.meta ||= parse_prefix_commet(content, index)
    end

    # file_json = {
    #   "remote_name" => "file.txt",
    #   "local_name" => "file.txt",
    #   "content" => "...",
    # }
    def file_jsons
      return @file_jsons if defined?(@file_jsons)

      (meta["FILES"] || []).flat_map do |line|
        local_name, alias_name = line.split("=>").map(&:strip)

        file_jsons = gist.file_jsons.select do |file_json|
          File.fnmatch?(alias_name || local_name, file_json['filename'])
        end

        file_jsons.map do |file_json|
          {
            'remote_name' => file_json['filename'],
            'local_name' => local_name,
            'content' => file_json['content'],
          }
        end
      end
    end

    def content
      self.attrs["content"]
    end

    def gist_repo
      json["id"]
    end
  end
end