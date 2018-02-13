require "render_me_pretty/version"
require "tilt/erb"
require "active_support/core_ext/string"

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

  person = Person.new
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
      template = Tilt::ERBTemplate.new(@path)
      template.render(@context)
    end
  end

  # http://stackoverflow.com/questions/1338960/ruby-templates-how-to-pass-variables-into-inlined-erb
  class Context
    def initialize(hash={})
      hash.each do |key, value|
        instance_variable_set('@' + key.to_s, value)
      end
    end

    def override_variables!(vars)
      vars.each do |key, value|
        instance_variable_set('@' + key.to_s, value)
      end
    end

    def self.load_helpers(base_folder)
      Dir.glob("#{base_folder}/**/*_helper.rb").each do |path|
        relative_path = path.sub("#{base_folder}/", "")
        class_name = File.basename(relative_path, '.rb').classify

        require path
        include const_get(class_name)
      end
    end
  end
end

      # template = IO.read(path)
      # begin
      #   ERB.new(template, nil, "-").result(binding)
      # rescue Exception => e
      #   puts e

      #   # how to know where ERB stopped? - https://www.ruby-forum.com/topic/182051
      #   # syntax errors have the (erb):xxx info in e.message
      #   # undefined variables have (erb):xxx info in e.backtrac
      #   error_info = e.message.split("\n").grep(/\(erb\)/)[0]
      #   error_info ||= e.backtrace.grep(/\(erb\)/)[0]
      #   raise unless error_info # unable to find the (erb):xxx: error line
      #   line = error_info.split(':')[1].to_i
      #   puts "Error evaluating ERB template on line #{line.to_s.colorize(:red)} of: #{path.sub(/^\.\//, '')}"

      #   template_lines = template.split("\n")
      #   context = 5 # lines of context
      #   top, bottom = [line-context-1, 0].max, line+context-1
      #   spacing = template_lines.size.to_s.size
      #   template_lines[top..bottom].each_with_index do |line_content, index|
      #     line_number = top+index+1
      #     if line_number == line
      #       printf("%#{spacing}d %s\n".colorize(:red), line_number, line_content)
      #     else
      #       printf("%#{spacing}d %s\n", line_number, line_content)
      #     end
      #   end
      #   exit 1 unless ENV['TEST']
      # end
