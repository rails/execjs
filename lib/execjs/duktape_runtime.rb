require "execjs/runtime"
require "json"

module ExecJS
  class DuktapeRuntime < Runtime
    class Context < Runtime::Context
      def initialize(runtime, source = "")
        @ctx = Duktape::Context.new

        source = encode(source)
        @ctx.exec_string(source, '(execjs)')
      rescue Duktape::SyntaxError => e
        raise RuntimeError, e.message
      rescue Duktape::Error => e
        raise ProgramError, e.message
      rescue Duktape::InternalError => e
        raise RuntimeError, e.message
      end

      def exec(source, options = {})
        eval "(function(){#{encode(source)}})()"
      end

      def eval(source, options = {})
        source = encode(source)

        if /\S/ =~ source
          unwrap(@ctx.eval_string("(#{source})", '(execjs)'))
        end
      rescue Duktape::SyntaxError => e
        raise RuntimeError, e.message
      rescue Duktape::Error => e
        raise ProgramError, e.message
      rescue Duktape::InternalError => e
        raise RuntimeError, e.message
      end

      def call(identifier, *args)
        unwrap(@ctx.call_prop(identifier.split("."), *args))
      rescue Duktape::SyntaxError => e
        raise RuntimeError, e.message
      rescue Duktape::Error => e
        raise ProgramError, e.message
      rescue Duktape::InternalError => e
        raise RuntimeError, e.message
      end

      def unwrap(obj)
        case obj
        when ::Duktape::ComplexObject
          nil
        when Array
          obj.map { |v| unwrap(v) }
        when Hash
          obj.inject({}) do |vs, (k, v)|
            vs[k] = unwrap(v)
            vs
          end
        else
          obj
        end
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
