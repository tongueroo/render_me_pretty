require "render_me_pretty/version"
require "tilt"

module RenderMePretty
  class Erb
    def initialize(path, context)
      @path = path
      @context = context
    end

    def render(variables={})
      template = Tilt::ERBTemplate.new(path)
      template.render(context)
    end
  end
end
