require "render_me_pretty/version"
require "tilt/erb"
require "active_support/core_ext/string"

=begin
Usage examples:

Variables at initialization:

  erb = RenderMePretty::Erb.new("/path/to/template.erb", a: 1)
  erb.render

Variables at render time:

  erb = RenderMePretty::Erb.new("/path/to/template.erb")
  erb.render(a: 1)

Variables at both initialization and render time:

  erb = RenderMePretty::Erb.new("/path/to/template.erb", a: 1)
  erb.render(a: "override", b: 3)

Helpers for context:

  RenderMePretty::Context.helpers_path!("lib/helpers")
    # Loads modules defined in lib/helpers folder and adds their methods
    # as helper methods to the context provided to the render call.
    # The helper classes must be defined like so FooHelper and foo_helper.rb.
=end
module RenderMePretty
  class Erb
    def initialize(path, variables={})
      @path = path
      @variables = variables
      @context = variables[:context] || Context.new(variables)
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

    # dont think I need this for tilt???
    # def get_binding
    #   binding
    # end

    def self.load_helpers(base)
      Dir.glob("#{base}/**/*_helper.rb").each do |path|
        relative_path = path.sub("#{base}/", "")
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
