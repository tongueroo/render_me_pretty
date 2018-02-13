require "active_support/core_ext/string"
require "colorize"

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
      @context.override_variables!(override_vars)
      template = IO.read(@path)
      ERB.new(template, nil, "-").result(@context.get_binding)
    rescue Exception => e
      handle_exception(e)
    end

    # How to know where ERB stopped? - https://www.ruby-forum.com/topic/182051
    # syntax errors have the (erb):xxx info in e.message
    # undefined variables have (erb):xxx info in e.backtrace
    def handle_exception(e)
      error_info = e.message.split("\n").grep(/\(erb\)/)[0]
      error_info ||= e.backtrace.grep(/\(erb\)/)[0]
      raise unless error_info # unable to find the (erb):xxx: error line

      line = error_info.split(':')[1].to_i
      io = StringIO.new
      io.puts "#{e.class} evaluating ERB template on line #{line.to_s.colorize(:red)} of: #{@path.sub(/^\.\//, '')}"

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

      # Append the original stack trace also
      io.puts("\nOriginal backtrace (last 5 lines):")
      lines = ENV['FULL_STACK_TRACE'] ? e.backtrace : e.backtrace[0..4]
      io.write(lines.join("\n"))
      io.puts("\nRe-run with FULL_STACK_TRACE=1 to see all lines")

      if ENV['TEST']
        io.string
      else
        puts io.string
        exit 1
      end
    end
  end
end