require "rbconfig"

module ExecJS
  class Error < ::StandardError; end
  class RuntimeError    < Error; end
  class ProgramError    < Error; end

  autoload :ExternalRuntime, "execjs/external_runtime"
  autoload :RhinoRuntime,    "execjs/rhino_runtime"
  autoload :Runtimes,        "execjs/runtimes"
  autoload :V8Runtime,       "execjs/v8_runtime"

  def self.exec(source)
    runtime.exec(source)
  end

  def self.eval(source)
    runtime.eval(source)
  end

  def self.runtime
    @runtime ||= Runtimes.best_available
  end

  def self.root
    @root ||= File.expand_path("../execjs", __FILE__)
  end

  def self.windows?
    @windows ||= RbConfig::CONFIG["host_os"] =~ /mswin|mingw/
  end
end
