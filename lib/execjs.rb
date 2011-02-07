module ExecJS
  class Error < ::StandardError; end
  class RuntimeError    < Error; end
  class ProgramError    < Error; end

  autoload :Runtimes, "execjs/runtimes"
end
