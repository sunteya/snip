require "terrapin"

module Snip
  module Shell
    module Ripgrep
      class << self
        def install_required!
          version
        rescue Terrapin::CommandNotFoundError => e
          raise "rg (ripgrep) is not installed"
        end

        def version
          @version ||= self.rg("--version").run
        end

        def search_snip
          install_required!

          output = self.rg("-l SNIP:", expected_outcodes: [ 0, 1 ]).run
          output.lines.map(&:strip)
        end

        def rg(*args)
          Terrapin::CommandLine.new("rg", *args)
        end
      end
    end
  end
end
