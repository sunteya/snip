require "rainbow"
require_relative "paper"
require_relative "gist"

module Snip
  module ThorUpdate
    def self.included(base)
      base.class_eval do
        desc "update <path/hash>", "update a snip"
        def update(path_or_hash)
          if File.exist?(path_or_hash)
            update_path(path_or_hash)
          else
            LocalPaper.scan.each do |local_paper|
              if local_paper.gist_repo == path_or_hash
                update_path(local_paper.path)
              end
            end
          end
        end

        no_commands do
          def update_path(path)
            dir = File.dirname(path)
            local_paper = LocalPaper.new(path)
            local_paper.parse
            unless local_paper.valid?
              puts Rainbow("File is not valid!").red
              return
            end

            gist = Gist.load(local_paper.gist_repo, verbose: true)

            remote_paper = gist.find_paper(local_paper.filename)
            print "Checking #{path} ... "
            if local_paper.nil?
              IO.write(path, remote_paper.content)
              puts Rainbow("Created").green
            elsif is_paper_changed?(local_paper, remote_paper)
              IO.write(path, remote_paper.content)
              puts Rainbow("Updated").green
            else
              puts Rainbow("No changes").yellow
            end

            old_file_infos = local_paper&.file_infos || []
            remote_paper.file_jsons.each do |file_json|
              file_path = File.join(dir, file_json[:filename])
              print "Checking #{file_path} ... "

              file_info = old_file_infos.detect do |info|
                info[:filename] == file_json[:filename]
              end

              old_file_infos.delete(file_info)
              if file_info.nil?
                IO.write(file_path, file_json[:content])
                puts Rainbow("Created").green
              elsif is_file_changed?(file_info, file_json)
                IO.write(file_path, file_json[:content])
                puts Rainbow("Updated").green
              else
                puts Rainbow("No changes").yellow
              end
            end

            old_file_infos.each do |file_info|
              puts "Deleting #{file_info[:path]} ... "
              File.delete(file_info[:path])
            end
          end

          def update_hash(hash)
          end
        end
      end
    end
  end
end
