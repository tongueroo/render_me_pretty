class RenderMePretty::Erb
  class BaseHandler
    def initialize(exception, path, layout_path=nil)
      @exception = exception
      @path = path
      @layout_path = layout_path
    end

    def handle
      line_number = find_line_number
      pretty_trace(line_number, full_message=true) # returns StringIO
    end

    def pretty_trace(error_line_number, full_message=true)
      io = StringIO.new

      message = full_message ? ": #{@exception.message}" : ""
      io.puts "#{@exception.class}#{message}".color(:red)

      pretty_path = template_path_with_error.sub(/^\.\//, '')
      io.puts "Error evaluating ERB template around line #{error_line_number.to_s.color(:red)} of: #{pretty_path}:"

      context = 5 # lines of context
      top, bottom = [error_line_number-context-1, 0].max, error_line_number+context-1

      lines = IO.read(template_path_with_error).split("\n")
      spacing = lines.size.to_s.size
      lines[top..bottom].each_with_index do |line_content, index|
        current_line_number = top+index+1
        if current_line_number == error_line_number
          io.printf("%#{spacing}d %s\n".color(:red), current_line_number, line_content)
        else
          io.printf("%#{spacing}d %s\n", current_line_number, line_content)
        end
      end

      io.puts backtrace_lines
      io
    end

    def template_path_with_error
      error_in_layout? ? @layout_path : @path
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
    def backtrace_lines
      full = ENV['FULL_BACKTRACE']
      if full
        lines = @exception.backtrace
      else
        lines = @exception.backtrace
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
      lines.unshift "\nOriginal backtrace#{full ? '' : ' (last 8 lines)'}:"
      # footer
      lines << "\nRe-run with FULL_BACKTRACE=1 to see all lines"
      lines.join("\n")
    end
  end
end
