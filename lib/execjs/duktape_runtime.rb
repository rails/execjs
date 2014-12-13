require "execjs/runtime"
require "json"

module ExecJS
  class DuktapeRuntime < Runtime
    class Context < Runtime::Context
      def initialize(runtime, source = "")
        @ctx = Duktape::Context.new

        normalize do
          @ctx.exec_string(encode(source), '(execjs)')
        end
      end

      def exec(source, options = {})
        return unless /\S/ =~ source

        normalize do
          @ctx.eval_string("(function(){#{encode(source)}})()", '(execjs)')
        end
      end

      def eval(source, options = {})
        return unless /\S/ =~ source

        normalize do
          @ctx.eval_string("(#{encode(source)})", '(execjs)')
        end
      end

      def call(identifier, *args)
        normalize do
          @ctx.call_prop(identifier.split("."), *args)
        end
      end

      private
        def normalize
          unwrap yield
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
