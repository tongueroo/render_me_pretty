require "render_me_pretty/version"
require "active_support/core_ext/string"
require "colorize"

module RenderMePretty
  autoload :Erb, 'render_me_pretty/erb'
  autoload :Context, 'render_me_pretty/context'

  def self.result(path, variables={})
    erb = Erb.new(path, variables)
    erb.render
  end

  extend self
end
