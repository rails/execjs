require "rbconfig"

module ExecJS
  VERSION = "1.0.0"

  class Error           < ::StandardError; end
  class RuntimeError              < Error; end
  class ProgramError              < Error; end
  class RuntimeUnavailable < RuntimeError; end

  autoload :ExternalRuntime,  "execjs/external_runtime"
  autoload :MustangRuntime,   "execjs/mustang_runtime"
  autoload :RubyRacerRuntime, "execjs/ruby_racer_runtime"
  autoload :RubyRhinoRuntime, "execjs/ruby_rhino_runtime"
  autoload :Runtimes,         "execjs/runtimes"

  class << self
    attr_reader :runtime

    def exec(source)
      runtime.exec(source)
    end

    def eval(source)
      runtime.eval(source)
    end

    def compile(source)
      runtime.compile(source)
    end

    def runtimes
      Runtimes.runtimes
    end

    def runtime=(runtime)
      raise RuntimeUnavailable, "#{runtime.name} is unavailable on this system" unless runtime.available?
      @runtime = runtime
    end

    def root
      @root ||= File.expand_path("../execjs", __FILE__)
    end

    def windows?
      @windows ||= RbConfig::CONFIG["host_os"] =~ /mswin|mingw/
    end
  end

  # Eagerly detect runtime
  self.runtime ||= Runtimes.best_available ||
    raise(RuntimeUnavailable, "Could not find a JavaScript runtime. See https://github.com/sstephenson/execjs for a list of available runtimes.")
end
