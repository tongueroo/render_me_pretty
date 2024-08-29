require "render_me_pretty/version"
require "active_support"
require "active_support/core_ext/string"
require "rainbow/ext/string"

module RenderMePretty
  autoload :Erb, "render_me_pretty/erb"

  def result(path, variables = {})
    erb = Erb.new(path, variables)
    erb.render
  end

  extend self
end
