require "thor"
require 'digest'

require_relative "thor_upload"
require_relative "thor_list"
require_relative "thor_update"
require_relative "thor_download"
require_relative "thor_outdated"

module Snip
  class CLI < Thor
    map "ls" => "list"

    include ThorList
    include ThorUpload
    include ThorUpdate
    include ThorDownload
    include ThorOutdated

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
