module Paperclip
  class CommandLine
    class << self
      attr_accessor :path
    end

    def initialize(binary, params = "", options = {})
      @binary            = binary.dup
      @params            = params.dup
      @options           = options.dup
      @swallow_stderr    = @options.delete(:swallow_stderr)
      @expected_outcodes = @options.delete(:expected_outcodes)
      @expected_outcodes ||= [0]
    end

    def command
      cmd = []
      cmd << full_path(@binary)
      cmd << interpolate(@params, @options)
      cmd << bit_bucket if @swallow_stderr
      cmd.join(" ")
    end

    def run
      output = `#{command}`
      unless @expected_outcodes.include?($?.exitstatus)
        raise Paperclip::PaperclipCommandLineError, "Command '#{command}' returned #{$?.exitstatus}. Expected #{@expected_outcodes.join(", ")}"
      end
      output
    end

    private

    def full_path(binary)
      [self.class.path, binary].compact.join("/")
    end

    def interpolate(pattern, vars)
      # interpolates :variables and :{variables}
      pattern.gsub(%r#:(?:\w+|\{\w+\})#) do |match|
        key = match[1..-1]
        key = key[1..-2] if key[0,1] == '{'
        if invalid_variables.include?(key)
          raise PaperclipCommandLineError,
            "Interpolation of #{key} isn't allowed."
        end
        shell_quote(vars[key.to_sym])
      end
    end

    def invalid_variables
      %w(expected_outcodes swallow_stderr)
    end

    def shell_quote(string)
      return "" if string.nil? or string.blank?
      string.split("'").map{|m| "'#{m}'" }.join("\\'")
    end

    def bit_bucket
      return "2>NUL" unless File.exist?("/dev/null")
      "2>/dev/null"
    end
  end
end
