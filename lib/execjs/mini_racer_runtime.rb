require "execjs/runtime"

module ExecJS
  class MiniRacerRuntime < Runtime
    class Context < Runtime::Context
      def initialize(runtime, source = "")
        source = encode(source)
        @context = ::MiniRacer::Context.new
        @context.eval(source)
      end

      def exec(source, options = {})
        source = encode(source)

        if /\S/ =~ source
          eval "(function(){#{source}})()"
        end
      end

      def eval(source, options = {})
        source = encode(source)

        if /\S/ =~ source
          @context.eval("(#{source})")
        end
      end

      def call(identifier, *args)
        # TODO optimise generate
        eval "#{identifier}.apply(this, #{::JSON.generate(args)})"
      end

    end

    def name
      "mini_racer (V8)"
    end

    def available?
      require "mini_racer"
      true
    rescue LoadError
      false
    end
  end
end
