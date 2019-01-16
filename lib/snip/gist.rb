require "snip"
require "open-uri"

module Snip
  class Gist
    attr_accessor :json
    def initialize(json)
      self.json = json
    end

    def repo
      json["id"]
    end

    def files
      @files ||= Hash[self.json["files"].map do |name, file_json|
        name = name.gsub(/^\[(snip|SNIP)\]/, "").strip
        [ name, file_json["content"] ]
      end]
    end

    def self.load(repo)
      json = JSON.parse(open("https://api.github.com/gists/#{repo}").read)
      Gist.new(json)
    end
  end
end
