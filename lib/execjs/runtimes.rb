module ExecJS
  module Runtimes
    autoload :Node, "execjs/runtimes/node"
    autoload :V8,   "execjs/runtimes/v8"

    def self.runtime
      V8.new
    end
  end
end
