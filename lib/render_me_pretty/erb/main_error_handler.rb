class RenderMePretty::Erb
  class MainErrorHandler < BaseHandler
    def handle
      line_number = find_line_number
      pretty_trace(line_number, full_message=true) # returns StringIO
    end

    # For general Tilt errors first line of the backtrace that contains the path
    # of the file we're rendeirng and has the line number. Example:
    #
    #   spec/fixtures/invalid.erb:2:in `block in singleton class'
    #   error_info = e.backtrace[0]
    def find_line_number
      lines = @exception.backtrace
      error_line = lines.select do |line|
        line.include?(@path)
      end.first
      error_line.split(':')[1].to_i
    end
  end
end
