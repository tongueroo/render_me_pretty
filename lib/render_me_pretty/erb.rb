# ## Usage examples:
#
# Given an example template /path/to/template.erb that contains:
#
#   a: <%= @a %>
#
### Variables at initialization
#
#   erb = RenderMePretty::Erb.new("/path/to/template.erb", a: 1)
#   erb.render
#
# Result: a: 1
#
### Variables at render time
#
#   erb = RenderMePretty::Erb.new("/path/to/template.erb")
#   erb.render(a: 2)
#
# Result: a: 2
#
### Variables at both initialization and render time:
#
#   erb = RenderMePretty::Erb.new("/path/to/template.erb", a: 3)
#   erb.render(a: "override", a: 4)
#
# Result: a: 4
#
# Variables at render time will override variables at initialization time.
#
## Context Scope
#
# If you want to use your own context object, pass it as a variable.  The context variable is specially treated as a context object.  Example:
#
#   person = Person.new # must implement get_binding
#   erb = RenderMePretty::Erb.new("/path/to/template.erb")
#   erb.render(context: person, a: 2)
#
# The context will be `person`.  So person methods and instance variables will be available in the ERB templates.
#
require "tilt"
require "tilt/erb"

module RenderMePretty
  class Erb
    autoload :BaseHandler, "render_me_pretty/erb/base_handler"
    autoload :SyntaxErrorHandler, "render_me_pretty/erb/syntax_error_handler"
    autoload :MainErrorHandler, "render_me_pretty/erb/main_error_handler"

    def initialize(path, variables = {})
      @path = path
      @init_vars = variables
      @context = variables.delete(:context)
      @layout_path = variables.delete(:layout)
    end

    # Usage:
    #
    #   render(context, a: 1, b: 2)
    #   render(a: 1, b: 2)
    #   render
    def render(*args)
      if args.last.is_a?(Hash)
        render_vars = args.pop
        @init_vars = @init_vars.merge(render_vars)
      end
      context = args[0]
      context ||= @context || Object.new

      context = context.clone # so we dont stomp the original object
      # override context's instance variables with init and render vars.
      @init_vars.each do |key, value|
        context.instance_variable_set("@" + key.to_s, value)
      end

      # https://github.com/gotar/dry-view/commit/39e3f96625bf90da2e51fb1fd437f18cedb9ae8c
      tilt_options = {trim: "-", default_encoding: "utf-8"}
      if @layout_path
        layout = Tilt::ERBTemplate.new(@layout_path, tilt_options)
      else
        # trim mode: https://searchcode.com/codesearch/view/77362792/
        template = Tilt::ERBTemplate.new(@path, tilt_options)
      end

      begin
        if @layout_path
          layout.render(context) do
            Tilt::ERBTemplate.new(@path, tilt_options).render(context)
          end
        else
          template.render(context)
        end
      rescue Exception => e
        if e.instance_of?(SystemExit) # allow exit to happen normally
          raise
        else
          handle_exception(e)
        end
      end
    end

    # Handles Tilt error in prettier manner.
    #
    # When there's a syntax error Tilt does not include the line nubmer of the
    # error in the backtrace it is instead included in the e.message itself.
    #
    # When for other errors the line_number is included in the backtrace.
    #
    # Refer to specs and uncomment puts out to see the different types of errors.
    def handle_exception(e)
      # puts "*" * 30
      # puts e.class.to_s.color(:cyan)
      # puts e.message.color(:cyan)
      # puts e.backtrace
      # puts "*" * 30
      handler = e.is_a?(SyntaxError) ?
                  SyntaxErrorHandler.new(e, @path, @layout_path) :
                  MainErrorHandler.new(e, @path, @layout_path)
      io = handler.handle
      print_result(io)
    end

    def print_result(io)
      if ENV["TEST"]
        io.string
      else
        puts io.string
        exit 1
      end
    end

    # Method produces a filtered original stack trace that can be appended to
    # the pretty backtrace output.
    #
    # It parses the original backtrace that looks something like this:
    #
    #   (erb):380:in `get_binding'
    #   /Users/tung/.rbenv/versions/2.5.0/lib/ruby/2.5.0/erb.rb:885:in `eval'
    #   /Users/tung/.rbenv/versions/2.5.0/lib/ruby/2.5.0/erb.rb:885:in `result'
    #   /Users/tung/src/tongueroo/lono/vendor/render_me_pretty/lib/render_me_pretty/erb.rb:67:in `render'
    #   /Users/tung/src/tongueroo/lono/vendor/render_me_pretty/lib/render_me_pretty.rb:11:in `result'
    #   /Users/tung/src/tongueroo/lono/lib/lono/template/template.rb:32:in `build'
    #   /Users/tung/src/tongueroo/lono/lib/lono/template/dsl.rb:82:in `block in build_templates'
    #   /Users/tung/src/tongueroo/lono/lib/lono/template/dsl.rb:81:in `each'
    def backtrace_lines(e)
      full = ENV["FULL_BACKTRACE"]
      lines = e.backtrace
      if full
      else
        # This filtering business makes is hiding useful info.
        # Think it was needed for ERB but Tilt provides a better stack trace.
        # Commenting out for now.

        # filter out internal lines
        # removal_index = lines.find_index { |l| l =~ %r[lib/render_me_pretty] }
        # lines = lines[removal_index..-1] # remove leading lines above the lib/
        # render_me_pretty lines by keeping lines past the removal index
        # lines.reject! { |l| l =~ %r[lib/render_me_pretty] } # now filter out
        # render_me_pretty lines
        lines = lines[0..7] # keep 8 lines
      end
      lines[0] = lines[0].color(:red)

      # header
      lines.unshift "\nOriginal backtrace#{full ? "" : " (last 8 lines)"}:"
      # footer
      lines << "\nRe-run with FULL_BACKTRACE=1 to see all lines"
      lines.join("\n")
    end
  end
end
