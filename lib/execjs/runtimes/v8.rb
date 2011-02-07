module ExecJS
  module Runtimes
    class V8 < Runtime
      def command(filename)
        "v8 #{filename}"
      end

      def runner_path
        File.expand_path('../v8.js', __FILE__)
      end
    end
  end
end
