require "execjs/runtime"
require "json"

module ExecJS
  class DuktapeRuntime < Runtime
    class Context < Runtime::Context
      def initialize(runtime, source = "")
        @ctx = Duktape::Context.new
        exec(source)
      end

      def exec(source, options = {})
        source = encode(source)

        js = <<-JS
          (function(program) { return JSON.stringify([program()]); })(function() { #{source} });
        JS

        if json = @ctx.eval_string(js, '(execjs)')
          ::JSON.parse(json, create_additions: false)[0]
        end
      rescue Duktape::SyntaxError => e
        raise RuntimeError, e.message
      rescue Duktape::Error => e
        raise ProgramError, e.message
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
