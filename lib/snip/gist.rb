require "snip"
require "json"
require "open-uri"
require_relative "remote_paper"

module Snip
  class Gist
    attr_accessor :json
    def initialize(json)
      self.json = json
    end

    def repo
      json["id"]
    end

    def kanban_json
      return @kanban_json if defined?(@kanban_json)

      @kanban_json = self.json['files'].values.detect do |attrs|
        attrs['filename'].start_with?("!")
      end
    end

    def papers
      return @papers if defined?(@papers)
      @papers = self.json['files'].values.map do |attrs|
        paper = RemotePaper.new(attrs, self)
        paper.parse
        paper.valid? ? paper : nil
      end.compact
    end

    def find_file_json(filename)
      paper = papers.detect { |paper| paper.filename == filename }
      return paper.attrs if paper

      self.json['files'].values.detect do |attrs|
        attrs['filename'] == filename
      end
    end

    def self.load(repo)
      json = JSON.parse(URI.open("https://api.github.com/gists/#{repo}").read)
      Gist.new(json)
    end
  end
end
