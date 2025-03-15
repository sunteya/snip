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
      content = attrs["content"]
      index = content.index(KEYWORD)
      return if index.nil?

      self.digest = Digest::MD5.hexdigest(content)
      self.meta = nil
      self.meta ||= parse_block_commet(content, index)
      self.meta ||= parse_prefix_commet(content, index)
    end

    def gist_repo
      json["id"]
    end
  end
end