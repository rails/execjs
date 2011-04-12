module ExecJS
  class MustangRuntime
    def name
      "Mustang (Mustang::V8)"
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
      Context.new(source)
    end

    def available?
      require "mustang"
      true
    rescue LoadError
      false
    end

  end
end

module ExecJS
  class MustangRuntime::Context

    def initialize(source = "")
      @v8_context = ::Mustang::Context.new
      @v8_context.eval(source)
    end

    def exec(source, options = {})
      if /\S/ =~ source
        eval "(function(){#{source}})()", options
      end
    end

    def eval(source, options = {})
      if /\S/ =~ source
        unbox @v8_context.eval("(#{source})")
      end
    end

    def call(properties, *args)
      unbox @v8_context.eval(properties).call(*args)
    rescue NoMethodError
      raise ProgramError
    end

    def unbox(value)
      case value
      when Mustang::V8::NullClass, Mustang::V8::UndefinedClass, Mustang::V8::Function
        nil
      when Mustang::V8::Array
        value.map { |v| unbox(v) }
      when Mustang::V8::SyntaxError
        raise RuntimeError
      when Mustang::V8::Error
        raise ProgramError
      else
        value.respond_to?(:delegate) ? value.delegate : value
      end
    end

  end
end
