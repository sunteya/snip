require "rainbow"
require_relative "local_paper"
require_relative "gist"

module Snip
  module CommandDownload2
    def self.included(base)
      base.class_eval do
        desc "download2 <repo_hash>", "checks for outdated snips"
        def download2(repo)
          gist = Gist.load(repo)
          papers = LocalPaper.scan.select do |paper|
            paper.gist_repo == repo
          end

          gist.files.each do |name, content|
            paper = papers.find { |paper| paper.filename == name }

            if paper
              path = paper.path
              print path
              IO.write(path, content)
              puts " | #{Rainbow('updated').green}"
            else
              IO.write(name, content)
              puts "#{name} | #{Rainbow('new').red}"
            end
          end
        end
      end
    end
  end
end
