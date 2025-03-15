require "spec_helper"
require "snip/paper"

RSpec.describe Snip::Paper do
  describe "#parse" do
    subject(:paper) { Snip::Paper.new(__FILE__) }
    before { expect(File).to receive(:read).and_return(content[1..].strip_heredoc) }

    context "block" do
      let(:content) { "
        /*
          SNIP: css
          FILES:
            - foo
        */
      " }

      it { is_expected.to have_attributes(meta: {
        "SNIP" => "css",
        "FILES" => [ "foo" ],
      }) }
    end

    context "prefix" do
      let(:content) { "
        # SNIP: ruby
        puts 'hello'
      " }

      it { is_expected.to have_attributes(meta: {
        "SNIP" => "ruby",
      }) }
    end
  end
end