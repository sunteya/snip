require "thor"
require "snip"

module Snip
  class CLI < Thor
    map "ls" => "list"

    desc "list", "list all of the snip file in current folder"
    def list
      papers = Paper.scan
      papers.each do |paper|
        print "#{paper.gist_repo}"
        print " [#{paper.gist_file_pattern}]" if paper.gist_file_pattern
        print " - #{paper.changelogs[0]}" if paper.changelogs.any?
        puts ""

        paper.files.each do |path, pattern|
          print " - #{path}"
          print " => #{pattern}" if pattern
          puts ""
        end

        puts ""
      end
    end
  end
end
