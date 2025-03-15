require "thor"

require_relative "paper"
require_relative "command_outdated"
require_relative "command_download"
require_relative "command_download2"
require_relative "thor_upload"
require_relative "thor_list"

module Snip
  class CLI < Thor
    map "ls" => "list"

    include ThorList
    include ThorUpload

    include CommandOutdated
    include CommandDownload
    include CommandDownload2
  end
end
