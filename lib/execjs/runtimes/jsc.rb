module ExecJS
  module Runtimes
    class JSC < Runtime
      def command(filename)
        "/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc #{filename}"
      end

      def runner_path
        File.expand_path('../v8.js', __FILE__)
      end
    end
  end
end
