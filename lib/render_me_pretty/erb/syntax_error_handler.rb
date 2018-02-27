require "byebug" if ENV['USER'] == 'tung'

class RenderMePretty::Erb
  class SyntaxErrorHandler < BaseHandler
    # spec/fixtures/invalid/syntax.erb:2: syntax error, unexpected ';', expecting ']'
    # );  if ENV['TEST' ; _erbout.<<(-" missing ending...
    #                   ^
    # spec/fixtures/invalid/syntax.erb:12: syntax error, unexpected keyword_end, expecting end-of-input
    # end;end;end;end
    #             ^~~
    #
    # We will only find the first line number for the error.
    def find_line_number
      # puts "=".colorize(:green) * 30
      # puts "@exception.backtrace: "
      # puts @exception.backtrace
      # puts "=".colorize(:green) * 30
      # puts "@exception.message: "
      # puts @exception.message
      # puts "=".colorize(:green) * 30


      # puts "template_path_with_error #{template_path_with_error.inspect}"
      pattern = Regexp.new("#{template_path_with_error}:(\\\d+): syntax error")
      lines = @exception.message.split("\n")
      found_line = lines.find do |line|
        line.match(pattern)
      end
      md = found_line.match(pattern)
      n = md[1].to_i # line_number
      # puts "n #{n}"
      n
    end

    def error_in_layout?
      # first line has the error info
      lines = @exception.message.split("\n")
      error_info = lines.first
      md = error_info.match(/(.*):(\d+): syntax error/)
      file = md[1]
      # puts "file #{file.inspect}"
      # puts "@layout_path #{@layout_path.inspect}"
      file == @layout_path
    end
  end
end
