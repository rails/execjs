require "json"
require "tempfile"

module ExecJS
  module Runtimes
    module Node
      extend self

      def exec(source)
        compile_to_tempfile(source) do |file|
          extract_result(exec_runtime("node #{file.path}"))
        end
      end

      def eval(source)
        if /\S/ =~ source
          exec("return eval(#{"(#{source})".to_json})")
        end
      end

      protected
        def compile_to_tempfile(source)
          tempfile = Tempfile.open("execjs")
          tempfile.write compile(source)
          tempfile.close
          yield tempfile
        ensure
          tempfile.close!
        end

        def compile(source)
          wrapper.sub('#{source}', source)
        end

        def wrapper
          @wrapper ||= IO.read(File.expand_path('../node.js', __FILE__))
        end

        def exec_runtime(command)
          output = `#{command} 2>&1`
          if $?.success?
            output
          else
            raise RuntimeError, output
          end
        end

        def extract_result(output)
          status, value = output.empty? ? [] : JSON.parse(output)
          if status == "ok"
            value
          else
            raise ProgramError, value
          end
        end
    end
  end
end
