require 'spec_helper'

describe RenderMePretty do
  let(:context) { TestContext.new }

  context "valid" do
    let(:path) { "spec/fixtures/valid.erb" }

    context "initial variables" do
      let(:erb) { RenderMePretty::Erb.new(path, a: 1) }
      it "#render" do
        out = erb.render(context)
        expect(out).to include "a: 1"
        # test helper methods also
        expect(out).to include "my_helper: my_helper value"
        expect(out).to include "hello test: hello tung"
      end
    end

    context "render time variables" do
      let(:erb) { RenderMePretty::Erb.new(path) }
      it "#render" do
        out = erb.render(context, a: 2)
        expect(out).to include "a: 2"
      end
    end

    context "both initial and render time variables" do
      let(:erb) { RenderMePretty::Erb.new(path, a: 3) }
      it "#render" do
        out = erb.render(context, a: 4)
        expect(out).to include "a: 4"
      end
    end

    it "convenience class method" do
      out = RenderMePretty.result(path, context: context)
      expect(out).to include "hello test: hello tung"
    end
  end

  context "invalid" do
    let(:erb) { RenderMePretty::Erb.new(path) }

    context "variable" do
      let(:path) { "spec/fixtures/invalid/variable.erb" }
      it "#render" do
        out = erb.render(context)
        # puts out
        expect(out).to include("2 <%= breakme %>")
      end
    end

    context "syntax" do
      let(:path) { "spec/fixtures/invalid/syntax.erb" }
      it "#render" do
        out = erb.render(context)
        # puts out
        # spec/fixtures/invalid/syntax.erb:2: syntax error, unexpected ';', expecting ']'
        # );  if ENV['TEST' ; _erbout.<<(-" missing ending...
                          # ^
        # spec/fixtures/invalid/syntax.erb:12: syntax error, unexpected keyword_end, expecting end-of-input
        # end;end;end;end
                    # ^~~
        expect(out).to include("ENV['TEST' ")
      end
    end
  end

  context "valid layout" do
    let(:erb) do
      RenderMePretty::Erb.new(path, layout: layout)
    end
    let(:path) { "spec/fixtures/layout/valid/child.erb" }
    let(:layout) { "spec/fixtures/layout/valid/parent.erb" }

    it "render with layout" do
      out = erb.render(context)
      # puts out # uncomment to debug
      expect(out).to include("top of file")
      expect(out).to include("child template")
    end
  end

  context "invalid child in layout" do
    let(:erb) do
      RenderMePretty::Erb.new(path, layout: layout)
    end
    let(:path) { "spec/fixtures/layout/invalid/child.erb" }
    let(:layout) { "spec/fixtures/layout/valid/parent.erb" }

    it "shows the exact line of error in template" do
      out = erb.render(context)
      # puts out # uncomment to debug
      expect(out).to include("1 <%= break_me_in_child %>")
    end
  end

  context "invalid parent layout" do
    let(:erb) do
      RenderMePretty::Erb.new(path, layout: layout)
    end
    let(:path) { "spec/fixtures/layout/valid/child.erb" }
    let(:layout) { "spec/fixtures/layout/invalid/parent.erb" }

    it "shows the exact line of error in template" do
      out = erb.render(context)
      # puts out # uncomment to debug
      expect(out).to include("2 <%= break_me_in_parent %>")
    end
  end
end
