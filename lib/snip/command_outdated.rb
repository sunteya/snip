require "rainbow"
require_relative "local_paper"
require_relative "gist"

module Snip
  module CommandOutdated
    def self.included(base)
      base.class_eval do
        desc "outdated", "checks for outdated snips"
        def outdated
          paper_mapping = Hash[LocalPaper.scan.map do |paper|
            print "Fetching metadata from GIST "
            print "."
            puts ""
            [ paper, Gist.load(paper.gist_repo) ]
          end]
          puts "" if paper_mapping.any?

          changed_count = 0
          paper_mapping.each do |paper, gist|
            changed = false
            out = StringIO.new
            out.print "#{paper.gist_repo}"
            out.print " - #{paper.changelogs[0]}" if paper.changelogs.any?
            out.puts ""

            paper.files.each do |path, custom|
              out.print " - #{path}"
              out.print " => #{custom}" if custom

              name = custom || File.basename(path)
              content = gist.files[name]
              if File.read(path) != content
                changed = true
                out.print " | #{Rainbow('changed').red}"
              end

              out.puts ""
            end

            if changed
              changed_count += 1
              puts out.string
              puts ""
            end
          end

          if changed_count == 0
            puts Rainbow("No snip file changes").green
          end
        end
      end
    end
  end
end
