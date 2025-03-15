require "rainbow"
require 'open3'
require_relative "local_paper"
require_relative "gist"
require_relative "shell/github"

module Snip
  module ThorUpload
    def self.included(base)
      base.class_eval do
        desc "upload [--force] <repo_hash>", "upload snip to github gist"
        method_option :force, type: :boolean, default: false
        def upload(repo)
          gist = Gist.load(repo)

          local_papers = LocalPaper.scan.select do |paper|
            paper.gist_repo == repo
          end

          performed = false
          local_papers.each do |local_paper|
            print "Uploading #{local_paper.path} to #{repo} ... "

            remote_paper = gist.papers.detect { |paper| paper.filename == local_paper.filename }
            if options[:force] || is_paper_changed?(local_paper, remote_paper)
              Shell::Github.gist_upload(repo, local_paper.filename, local_paper.path)
              puts Rainbow("Success!").green
              performed = true
            else
              puts Rainbow("skip, no changes").yellow
            end

            local_paper.file_infos.each do |info|
              print "Uploading #{info[:path]} to #{repo} ... "
              if options[:force] || is_file_changed?(info, gist)
                Shell::Github.gist_upload(repo, info[:filename], info[:path])
                puts Rainbow("Success!").green
                performed = true
              else
                puts Rainbow("skip, no changes").yellow
              end
            end
          end

          if performed && gist.kanban_json
            print "Touch kanban file ... "
            Shell::Github.gist_file_touch(repo, gist.kanban_json)
            puts Rainbow("Success!").green
          end
        end

        no_commands do
          def is_paper_changed?(local_paper, remote_paper)
            return true if remote_paper.nil?
            local_paper.digest != remote_paper.digest
          end

          def is_file_changed?(info, gist)
            gist_file_json = gist.find_file_json(info[:filename])
            return true if gist_file_json.nil?

            local_digest = Digest::MD5.hexdigest(File.read(info[:path]))
            remote_digest = Digest::MD5.hexdigest(gist_file_json['content'])
            local_digest != remote_digest
          end
        end
      end
    end
  end
end
