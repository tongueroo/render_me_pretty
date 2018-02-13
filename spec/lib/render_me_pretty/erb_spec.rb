require 'spec_helper'

RenderMePretty::Context.load_helpers("./spec/fixtures/helpers")

describe RenderMePretty do
  context "erb without initial variables" do
    let(:erb) do
      RenderMePretty::Erb.new(path)
    end
    let(:path) { "spec/fixtures/valid.erb" }

    context "valid" do
      it "#render" do
        out = erb.render
        puts out
        expect(out).to include "my_helper value"
      end
    end
  end
end
