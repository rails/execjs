module ExecJS
  module Runtimes
    def self.runtime
      V8
    end

    def self.runner_path(path)
      File.expand_path("../runtimes/#{path}", __FILE__)
    end

    JSC = Runtime.new(
      :command => "/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc",
      :runner_path => runner_path("jsc.js")
    )

    Node = Runtime.new(
      :command => "node",
      :runner_path => runner_path("node.js")
    )
    )

    V8 = Runtime.new(
      :command => "v8",
      :runner_path => runner_path("v8.js")
    )
  end
end
