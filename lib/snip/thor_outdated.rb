require "rainbow"
require_relative "local_paper"
require_relative "gist"

module Snip
  module ThorOutdated
    def self.included(base)
      base.class_eval do
        desc "outdated [gist_repo]", "checks for outdated snips"
        def outdated(gist_repo = nil)
          grouped_local_papers = LocalPaper.scan.filter do |paper|
            gist_repo.nil? || paper.gist_repo == gist_repo
          end.group_by { |paper| paper.gist_repo }

          print "Fetching metadata from GIST "
          gist_mapping = grouped_local_papers.transform_values do |local_papers|
            print "."
            gist_repo = local_papers.first.gist_repo
            Gist.load(gist_repo)
          end
          puts ""

          grouped_local_papers.each do |gist_repo, local_papers|
            gist = gist_mapping[gist_repo]

            outdated_local_papers = local_papers.find_all do |local_paper|
              remote_paper = gist.find_paper(local_paper.filename)
              is_paper_changed?(local_paper, remote_paper)
            end

            if outdated_local_papers.any?
              puts Rainbow("https://gist.github.com/#{gist_repo}").yellow
              outdated_local_papers.each do |local_paper|
                print " - #{local_paper.path}"

                remote_paper = gist.find_paper(local_paper.filename)
                if remote_paper.nil?
                  puts " | #{Rainbow('not found').red}"
                else
                  if local_paper.changelogs[0] != remote_paper.changelogs[0]
                    print " - "
                    print Rainbow(local_paper.changelogs[0]).strike.red
                    print " | "
                    print Rainbow(remote_paper.changelogs[0]).green
                    puts ""
                  else
                    puts ""
                  end
                end
              end
            end
          end

          # paper_mapping = Hash[LocalPaper.scan.map do |paper|
          #   print "."
          #   puts ""
          #   [ paper, Gist.load(paper.gist_repo) ]
          # end]
          # puts "" if paper_mapping.any?

          # changed_count = 0
          # paper_mapping.each do |paper, gist|
          #   changed = false
          #   out = StringIO.new
          #   out.print "#{paper.gist_repo}"
          #   out.print " - #{paper.changelogs[0]}" if paper.changelogs.any?
          #   out.puts ""

          #   paper.files.each do |path, custom|
          #     out.print " - #{path}"
          #     out.print " => #{custom}" if custom

          #     name = custom || File.basename(path)
          #     content = gist.files[name]
          #     if File.read(path) != content
          #       changed = true
          #       out.print " | #{Rainbow('changed').red}"
          #     end

          #     out.puts ""
          #   end

          #   if changed
          #     changed_count += 1
          #     puts out.string
          #     puts ""
          #   end
          # end

          # if changed_count == 0
          #   puts Rainbow("No snip file changes").green
          # end
        end
      end
    end
  end
end
