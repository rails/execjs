module ExecJS
  module Runtimes
    class Node < Runtime
      def command(filename)
        "node #{filename}"
      end

      def runner_path
        File.expand_path('../node.js', __FILE__)
      end
    end
  end
end
