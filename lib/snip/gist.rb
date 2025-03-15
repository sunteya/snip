require "snip"
require "json"
require "open-uri"
require_relative "remote_paper"

module Snip
  class Gist
    attr_accessor :json

    attr_accessor :papers
    attr_accessor :file_jsons
    attr_accessor :kanban_json

    def initialize(json)
      self.json = json

      self.file_jsons = []
      self.papers = []

      self.json['files'].values.map do |file_json|
        if file_json['filename'].start_with?("!")
          self.kanban_json = file_json
          next
        end

        paper = RemotePaper.new(file_json, self)
        paper.parse
        if paper.valid?
          self.papers << paper
        else
          self.file_jsons << file_json
        end
      end
    end

    def repo
      json["id"]
    end


    def find_file_json(filename)
      self.file_jsons.detect do |file_json|
        file_json['filename'] == filename
      end
    end

    def find_paper(filename)
      remote_paper = self.papers.detect { |paper| paper.filename == filename }
    end

    def self.load(repo, options = {})
      @cache ||= {}
      return @cache[repo] if @cache.key?(repo)

      json = JSON.parse(URI.open("https://api.github.com/gists/#{repo}").read)
      if options[:verbose]
        puts "Fetch gist #{repo} ... "
      end

      @cache[repo] = Gist.new(json)
      @cache[repo]
    end
  end
end
