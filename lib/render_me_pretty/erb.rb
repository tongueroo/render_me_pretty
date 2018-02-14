=begin
## Usage examples:

Given an example template /path/to/template.erb that contains:

  a: <%= @a %>

### Variables at initialization

  erb = RenderMePretty::Erb.new("/path/to/template.erb", a: 1)
  erb.render

Result: a: 1

### Variables at render time

  erb = RenderMePretty::Erb.new("/path/to/template.erb")
  erb.render(a: 2)

Result: a: 2

### Variables at both initialization and render time:

  erb = RenderMePretty::Erb.new("/path/to/template.erb", a: 3)
  erb.render(a: "override", a: 4)

Result: a: 4

Variables at render time will override variables at initialization time.

## Context Helpers

When no context is provided, a built-in context object is created. You can add helpers to the built-in context object with:

  RenderMePretty::Context.load_helpers("lib/helpers")

This loads modules defined in `lib/helpers` folder and adds their methods of the built-in context object. The helper classes must be defined with the following convetion: FooHelper and foo_helper.rb.

Note, helpers will only work with the built-in context scope.  If you are passing in your own context object to be used, then you should handle adding helper methods to that context object yourself.

## Custom Context Scope

A built-in context object is provided for convenience. If you want to use your own context object, pass it as a variable.  The context variable is specially treated as a context object.  Example:

  person = Person.new # must implement get_binding
  erb = RenderMePretty::Erb.new("/path/to/template.erb")
  erb.render(context: person, a: 2)

The context will be `person`.  So person methods and instance variables will be available in the ERB templates.

=end
require 'tilt/erb'

module RenderMePretty
  class Erb
    def initialize(path, variables={})
      @path = path
      @variables = variables
      if variables[:context]
        @context = variables.delete(:context)
      else
        @context = Context.new(variables)
      end
    end

    def render(override_vars={})
      # override_variables does not exist in custom context classes
      # so this is a bad design.
      @context.override_variables!(override_vars)

      template = Tilt::ERBTemplate.new(@path)
      template.render(@context)
    rescue Exception => e
      handle_exception(e)
    end

    # def render(override_vars={})
    #   @context.override_variables!(override_vars)
    #   puts "@context #{@context.inspect}"
    #   template = IO.read(@path)
    #   ERB.new(template, nil, "-").result(@context.get_binding)
    # rescue Exception => e
    #   handle_exception(e)
    # end

    # handles Tilt error
    def handle_exception(e)
      # first line of the baacktrace for Tilt has the line number
      # spec/fixtures/invalid.erb:2:in `block in singleton class'
      error_info = e.backtrace[0]
      error_line_number = error_info.split(':')[1].to_i
      pretty_error(e, error_line_number)
    end

    def pretty_error(e, line)
      pretty_path = @path.sub(/^\.\//, '')
      io = StringIO.new
      io.puts "#{e.class}: #{e.message}"
      io.puts "Error evaluating ERB template on line #{line.to_s.colorize(:red)} of: #{pretty_path}:"

      template = IO.read(@path)
      template_lines = template.split("\n")
      context = 5 # lines of context
      top, bottom = [line-context-1, 0].max, line+context-1
      spacing = template_lines.size.to_s.size
      template_lines[top..bottom].each_with_index do |line_content, index|
        line_number = top+index+1
        if line_number == line
          io.printf("%#{spacing}d %s\n".colorize(:red), line_number, line_content)
        else
          io.printf("%#{spacing}d %s\n", line_number, line_content)
        end
      end

      io.puts backtrace_lines(e)

      if ENV['TEST']
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
      full = ENV['FULL_STACK_TRACE']
      if full
        lines = e.backtrace
      else
        lines = e.backtrace
        # filter out internal lines
        removal_index = lines.find_index { |l| l =~ %r[lib/render_me_pretty] }
        lines = lines[removal_index..-1] # remove leading lines above the lib/
          # render_me_pretty lines by keeping lines past the removal index
        lines.reject! { |l| l =~ %r[lib/render_me_pretty] } # now filter out
          # render_me_pretty lines
        lines = lines[0..7] # keep 8 lines
        lines[0] = lines[0].colorize(:red)
      end

      # header
      lines.unshift "\nOriginal filtered backtrace#{full ? '' : ' (last 8 lines)'}:"
      # footer
      lines << "\nRe-run with FULL_STACK_TRACE=1 to see all lines"
      lines.join("\n")
    end
  end
end
