require "terrapin"
require 'tempfile'

module Snip
  module Shell
    module Github
      class << self
        def install_required!
          version
        rescue Terrapin::CommandNotFoundError => e
          raise "gh (GitHub CLI) is not installed"
        end

        def version
          @version ||= self.gh("--version").run
        end

        def gist_upload(repo, filename, path)
          install_required!

          self.gh("gist edit :repo -a :filename :path").run({
            repo: repo,
            filename: filename,
            path: path,
          })
        end

        def gist_file_touch(repo, json)
          install_required!

          begin
            tmp_file = ::Tempfile.new(json['filename'])
            IO.write(tmp_file.path, json['content'])

            self.gh("gist edit :repo -a :filename :path").run({
              repo: repo,
              filename: json['filename'],
              path: tmp_file.path,
            })
          ensure
            tmp_file.unlink
          end
        end

        def gh(*args)
          Terrapin::CommandLine.new("gh", *args)
        end
      end
    end
  end
end
