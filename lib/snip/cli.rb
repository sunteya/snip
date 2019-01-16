require "thor"

require_relative "paper"
require_relative "command_outdated"
require "rainbow"

module Snip
  class CLI < Thor
    map "ls" => "list"

    desc "list", "list all of the snip file in current folder"
    def list
      Paper.scan.each do |paper|
        print "#{paper.gist_repo}"
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

    include CommandOutdated
  end
end
