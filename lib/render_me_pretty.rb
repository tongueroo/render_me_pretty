require "render_me_pretty/version"
require "active_support/core_ext/string"
require "colorize"

module RenderMePretty
  autoload :Erb, 'render_me_pretty/erb'
  autoload :Context, 'render_me_pretty/context'

  def result(path, variables={})
    erb = Erb.new(path, variables)
    erb.render
  end

  # convenience wrapper
  def load_helpers(base_folder)
    RenderMePretty::Context.load_helpers(base_folder)
  end

  extend self
end
