module ExecJS
  class Error < ::StandardError; end
  class RuntimeError    < Error; end
  class ProgramError    < Error; end

  autoload :ExternalRuntime, "execjs/external_runtime"
  autoload :Runtimes,        "execjs/runtimes"

  def self.exec(source)
    runtime.exec(source)
  end

  def self.eval(source)
    runtime.eval(source)
  end

  def self.runtime
    @runtime ||= Runtimes.best_available
  end
end
