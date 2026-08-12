require "rbconfig"

module ExecJS
  class Error           < ::StandardError; end
  class RuntimeError              < Error; end
  class ProgramError              < Error; end
  class RuntimeUnavailable < RuntimeError; end

  class << self
    def runtime=(runtime)
      raise RuntimeUnavailable, "#{runtime.name} is unavailable on this system" unless runtime.available?

      @runtime = runtime
    end

    def runtime
      @runtime ||= Runtimes.autodetect
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
      @root ||= File.expand_path('execjs', __dir__)
    end

    def windows?
      @windows ||= RbConfig::CONFIG["host_os"].to_s.match?(/mswin|mingw/)
    end

    def cygwin?
      @cygwin ||= RbConfig::CONFIG["host_os"].to_s.match?(/cygwin/)
    end
  end
end

# Must load the remainder of the library files _after_ the above module methods
# have been defined because the ExternalRuntime class uses 'ExecJS.windows?' in
# a switch-yard that defines a platform-specific version of the 'exec_runtime'
# method at the time the class is loaded
require "execjs/runtimes"
