module ExecJS
  class RubyRacerRuntime
    def name
      "therubyracer (V8)"
    end

    def exec(source)
      if /\S/ =~ source
        eval "(function(){#{source}})()"
      end
    end

    def eval(source)
      if /\S/ =~ source
        context = ::V8::Context.new
        unbox context.eval("(#{source})")
      end
    rescue ::V8::JSError => e
      if e.value["name"] == "SyntaxError"
        raise RuntimeError, e
      else
        raise ProgramError, e
      end
    end

    def available?
      require "v8"
      true
    rescue LoadError
      false
    end

    def unbox(value)
      case value
      when ::V8::Function
        nil
      when ::V8::Array
        value.map { |v| unbox(v) }
      when ::V8::Object
        value.inject({}) do |vs, (k, v)|
          vs[k] = unbox(v) unless v.is_a?(::V8::Function)
          vs
        end
      else
        value
      end
    end
  end
end
