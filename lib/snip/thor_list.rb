require "rainbow"
require_relative "local_paper"
require_relative "gist"

module Snip
  module ThorList
    def self.included(base)
      base.class_eval do

        desc "list", "list all of the snip file in current folder"
        def list
          papers = LocalPaper.scan
          grouped = papers.group_by { |paper| paper.gist_repo }

          grouped.each do |gist_repo, papers|
            puts Rainbow(Gist.github_gist_url(gist_repo)).green

            papers.each do |paper|
              print " - #{paper.path}"
              print " #{Rainbow(paper.changelogs[0]).bright.white}" if paper.changelogs.any?
              puts ""

              paper.file_infos.each do |info|
                puts "   #{info[:path]}"
              end
            end

            puts ""
          end
        end

      end
    end
  end
end
