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
        unwrap(@ctx.eval_string("(function() { #{source} })();", '(execjs)'))
      rescue Duktape::SyntaxError => e
        raise RuntimeError, e.message
      rescue Duktape::Error => e
        raise ProgramError, e.message
      end

      def unwrap(obj)
        case obj
        when ::Duktape::ComplexObject
          nil
        when Array
          obj.map { |v| unwrap(v) }
        when Hash
          obj.inject({}) do |vs, (k, v)|
            v = unwrap(v)
            vs[k] = v if v
            vs
          end
        when String
          obj.force_encoding('UTF-8')
        else
          obj
        end
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
