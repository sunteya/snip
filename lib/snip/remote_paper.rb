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
    #   filename: "file.txt",
    #   content: "...",
    # }
    def file_jsons
      return @file_jsons if defined?(@file_jsons)

      (meta["FILES"] || []).flat_map do |pattern|
        file_jsons = gist.file_jsons.find_all do |file_json|
          File.fnmatch?(pattern, file_json['filename'])
        end

        file_jsons.map do |file_json|
          {
            filename: file_json['filename'],
            content: file_json['content'],
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