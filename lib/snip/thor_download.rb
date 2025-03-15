require "rainbow"
require_relative "local_paper"
require_relative "gist"

module Snip
  module ThorDownload
    def self.included(base)
      base.class_eval do
        desc "download <repo_hash>", "download a snip gist"
        def download(repo)
          puts "Fetch gist #{repo} ... "
          gist = Gist.load(repo)

          local_papers = LocalPaper.scan.select do |paper|
            paper.gist_repo == repo
          end

          gist.papers.each do |paper|
            local_paper = local_papers.find { |p| p.filename == paper.filename }

            if local_paper
              update_path(local_paper.path)
            else
              print "Download #{paper.filename} ... "
              path = File.join(".", paper.filename)
              IO.write(path, paper.content)
              puts Rainbow("Created").green

              update_path(path)
            end
          end
        end
      end
    end
  end
end
