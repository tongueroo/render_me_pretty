require 'spec_helper'

RenderMePretty::Context.load_helpers("./spec/fixtures/helpers")

describe RenderMePretty do
  context "initial variables" do
    let(:erb) do
      RenderMePretty::Erb.new(path, a: 1)
    end
    let(:path) { "spec/fixtures/valid.erb" }

    context "valid" do
      it "#render" do
        out = erb.render
        expect(out).to include "a: 1"
      end
    end
  end

  context "render time variables" do
    let(:erb) do
      RenderMePretty::Erb.new(path)
    end
    let(:path) { "spec/fixtures/valid.erb" }

    context "valid" do
      it "#render" do
        out = erb.render(a: 2)
        expect(out).to include "a: 2"
      end
    end
  end

  context "both initial and render time variables" do
    let(:erb) do
      RenderMePretty::Erb.new(path, a: 3)
    end
    let(:path) { "spec/fixtures/valid.erb" }

    context "valid" do
      it "#render" do
        out = erb.render(a: 4)
        expect(out).to include "a: 4"
      end
    end
  end
end
