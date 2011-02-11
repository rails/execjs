module ExecJS
  class RubyRhinoRuntime
    class Context
      def initialize
        @rhino_context = ::Rhino::Context.new
      end

      def exec(source)
        if /\S/ =~ source
          eval "(function(){#{source}})()"
        end
      end

      def eval(source)
        if /\S/ =~ source
          unbox @rhino_context.eval("(#{source})")
        end
      rescue ::Rhino::JavascriptError => e
        if e.message == "syntax error"
          raise RuntimeError, e
        else
          raise ProgramError, e
        end
      end

      def unbox(value)
        case value
        when ::Rhino::NativeFunction
          nil
        when ::Rhino::NativeObject
          value.inject({}) do |vs, (k, v)|
            vs[k] = unbox(v) unless v.is_a?(::Rhino::NativeFunction)
            vs
          end
        else
          value
        end
      end
    end

    def name
      "therubyrhino (Rhino)"
    end

    def exec(source)
      context = Context.new
      context.exec(source)
    end

    def eval(source)
      context = Context.new
      context.eval(source)
    end

    def compile(source)
      context = Context.new
      context.exec(source)
      context
    end

    def available?
      require "rhino"
      true
    rescue LoadError
      false
    end
  end
end
