module ExecJS
  class Error < ::StandardError; end
  class RuntimeError    < Error; end
  class ProgramError    < Error; end

  autoload :Runtime,  "execjs/runtime"
  autoload :Runtimes, "execjs/runtimes"

  def self.exec(source)
    runtime.exec(source)
  end

  def self.eval(source)
    runtime.eval(source)
  end

  def self.runtime
    @runtime ||= Runtimes.runtime
  end
end
