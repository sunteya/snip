require "thor"
require 'digest'

require_relative "paper"
require_relative "command_outdated"
require_relative "command_download2"

require_relative "thor_upload"
require_relative "thor_list"
require_relative "thor_update"

module Snip
  class CLI < Thor
    map "ls" => "list"

    include ThorList
    include ThorUpload
    include ThorUpdate

    include CommandOutdated
    include CommandDownload2

    no_commands do
      def is_paper_changed?(local_paper, remote_paper)
        return true if remote_paper.nil?
        local_paper.digest != remote_paper.digest
      end

      def is_file_changed?(info, gist_file_json)
        return true if gist_file_json.nil?

        local_digest = Digest::MD5.hexdigest(File.read(info[:path]))
        remote_digest = Digest::MD5.hexdigest(gist_file_json[:content])
        local_digest != remote_digest
      end
    end
  end
end
