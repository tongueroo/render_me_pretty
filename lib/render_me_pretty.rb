require "render_me_pretty/version"
require "active_support/core_ext/string"
require "colorize"

module RenderMePretty
  autoload :Erb, 'render_me_pretty/erb'

  def result(path, variables={})
    erb = Erb.new(path, variables)
    erb.render
  end

  extend self
end
