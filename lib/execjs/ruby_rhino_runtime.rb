module ExecJS
  class RubyRhinoRuntime
    def initialize(options)
    end

    def exec(source)
      if /\S/ =~ source
        eval "(function(){#{source}})()"
      end
    end

    def eval(source)
      if /\S/ =~ source
        context = ::Rhino::Context.new
        unbox context.eval("(#{source})")
      end
    rescue ::Rhino::JavascriptError => e
      if e.message == "syntax error"
        raise RuntimeError, e
      else
        raise ProgramError, e
      end
    end

    def available?
      require "rhino"
      true
    rescue LoadError
      false
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
end
