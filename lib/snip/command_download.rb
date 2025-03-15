require "rainbow"
require_relative "paper"
require_relative "gist"

module Snip
  module CommandDownload
    def self.included(base)
      base.class_eval do
        desc "download <path>", "checks for outdated snips"
        def download(path)
          unless File.exist?(path)
            puts Rainbow("File not found!").red
            return
          end

          paper = Paper.new(path)
          unless paper.valid?
            puts Rainbow("File is not valid!").red
            return
          end

          gist = Gist.load(paper.gist_repo)
          paper.files.each do |path, custom|
            name = custom || File.basename(path)
            print path

            if gist.files.key?(name)
              content = gist.files[name]
              IO.write(path, content)
              puts " | #{Rainbow('success').green}"
            else
              puts " | #{Rainbow('not found!!').red}"
            end

            puts ""
          end
        end
      end
    end
  end
end
