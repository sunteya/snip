require_relative "paper"

module Snip
  class DummyPaper < Paper
    attr_accessor :gist_repo

    def initialize(path, gist_repo)
      self.path = path
    end

    def file_infos
      []
    end
  end
end