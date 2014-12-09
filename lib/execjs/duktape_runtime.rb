require "execjs/runtime"
require "json"

module ExecJS
  class DuktapeRuntime < Runtime
    class Context < Runtime::Context
      def initialize(runtime, source = "")
        @ctx = Duktape::Context.new

        # Disable CJS
        exec("module = exports = require = undefined")
        exec(source)
      end

      def exec(source, options = {})
        source = encode(source)

        js = <<-JS
          (function(program, execJS) { return execJS(program); })(function() { #{source}
          }, function(program) {
            try {
              return JSON.stringify(['ok', program()]);
            } catch (err) {
              return JSON.stringify(['err', '' + err]);
            }
          });
        JS

        if json = @ctx.eval_string(js, '(execjs)')
          status, value = ::JSON.parse(json, create_additions: false)
          if status == "ok"
            value
          elsif value =~ /SyntaxError:/
            raise RuntimeError, value
          else
            raise ProgramError, value
          end
        end
      rescue Duktape::SyntaxError => e
        raise RuntimeError, e.message
      end

      def eval(source, options = {})
        source = encode(source)

        if /\S/ =~ source
          exec("return eval(#{::JSON.generate("(#{source})", quirks_mode: true)})")
        end
      end

      def call(identifier, *args)
        eval "#{identifier}.apply(this, #{::JSON.generate(args)})"
      end
    end

    def name
      "Duktape"
    end

    def available?
      require "duktape"
      true
    rescue LoadError
      false
    end
  end
end
