class RenderMePretty::Erb
  class SyntaxErrorHandler < BaseHandler
    def handle
      line_number = find_line_number
      pretty_trace(line_number, full_message=false)
    end

    # spec/fixtures/invalid/syntax.erb:2: syntax error, unexpected ';', expecting ']'
    # );  if ENV['TEST' ; _erbout.<<(-" missing ending...
    #                   ^
    # spec/fixtures/invalid/syntax.erb:12: syntax error, unexpected keyword_end, expecting end-of-input
    # end;end;end;end
    #             ^~~
    #
    # We will only find the first line number for the error.
    def find_line_number
      pattern = Regexp.new("#{@path}:(\\\d+): syntax error")
      lines = @exception.message.split("\n")
      found_line = lines.find do |line|
        line.match(pattern)
      end
      md = found_line.match(pattern)
      md[1].to_i # line_number
    end
  end
end
