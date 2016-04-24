require "execjs/version"
require "rbconfig"

module ExecJS
  class Error           < ::StandardError; end
  
  class RuntimeError < Error
    # Stores the unmarshaled JavaScript error information if it was available (type, message etc.)
    attr_accessor :metadata
  end
  
  class ProgramError < Error
    # Stores the unmarshaled JavaScript error information if it was available (type, message etc.)
    attr_accessor :metadata
  end
  
  class RuntimeUnavailable < RuntimeError; end

  class << self
    attr_reader :runtime

    def runtime=(runtime)
      raise RuntimeUnavailable, "#{runtime.name} is unavailable on this system" unless runtime.available?
      @runtime = runtime
    end

    def exec(source, options = {})
      runtime.exec(source, options)
    end

    def eval(source, options = {})
      runtime.eval(source, options)
    end

    def compile(source, options = {})
      runtime.compile(source, options)
    end

    def root
      @root ||= File.expand_path("..", __FILE__)
    end

    def windows?
      @windows ||= RbConfig::CONFIG["host_os"] =~ /mswin|mingw/
    end

    def cygwin?
      @cygwin ||= RbConfig::CONFIG["host_os"] =~ /cygwin/
    end
  end
end
