module ExecJS
  module Runtimes
    def self.best_available
      runtimes.find(&:available?)
    end

    def self.runtimes
      @runtimes ||= []
    end

    def self.define_runtime(name, options)
      klass = options[:as] || ExternalRuntime
      runtimes.push runtime = klass.new(options)
      const_set(name, runtime)
    end

    define_runtime :V8,
      :as => V8Runtime

    define_runtime :Rhino,
      :as => RhinoRuntime

    define_runtime :ExternalV8,
      :command => "v8",
      :test_args => "--help",
      :test_match => /--crankshaft/,
      :runner_path => ExecJS.root + "/support/basic_runner.js"

    define_runtime :Node,
      :command => ["nodejs", "node"],
      :runner_path => ExecJS.root + "/support/node_runner.js"

    define_runtime :JSC,
      :command => "/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc",
      :runner_path => ExecJS.root + "/support/basic_runner.js"

    define_runtime :Spidermonkey,
      :command => "js",
      :runner_path => ExecJS.root + "/support/basic_runner.js"

    define_runtime :JScript,
      :command => "cscript //E:jscript //Nologo",
      :runner_path => ExecJS.root + "/support/jscript_runner.js"
  end
end
