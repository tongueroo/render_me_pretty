require 'spec_helper'

RenderMePretty::Context.load_helpers("./spec/fixtures/helpers")

describe RenderMePretty do
  context "valid" do
    let(:path) { "spec/fixtures/valid.erb" }

    context "initial variables" do
      let(:erb) { RenderMePretty::Erb.new(path, a: 1) }
      it "#render" do
        out = erb.render
        expect(out).to include "a: 1"
        # test helper methods also
        expect(out).to include "my_helper: my_helper value"
        expect(out).to include "hello test: hello tung"
      end
    end

    context "render time variables" do
      let(:erb) { RenderMePretty::Erb.new(path) }
      it "#render" do
        out = erb.render(a: 2)
        expect(out).to include "a: 2"
      end
    end

    context "both initial and render time variables" do
      let(:erb) { RenderMePretty::Erb.new(path, a: 3) }
      it "#render" do
        out = erb.render(a: 4)
        expect(out).to include "a: 4"
      end
    end

    it "convenience class method" do
      out = RenderMePretty.result(path)
      expect(out).to include "hello test: hello tung"
    end
  end

  context "invalid" do
    let(:path) { "spec/fixtures/invalid.erb" }
    let(:erb) { RenderMePretty::Erb.new(path) }
    it "#render" do
      out = erb.render
      puts out
      exit
      expect(out).to include("2 <%= sdsd %>")
    end
  end
end
