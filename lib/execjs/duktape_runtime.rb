require "execjs/runtime"
require "json"

module ExecJS
  class DuktapeRuntime < Runtime
    class Context < Runtime::Context
      def initialize(runtime, source = "")
        @ctx = Duktape::Context.new(complex_object: nil)
        @ctx.exec_string(encode(source), '(execjs)')
      rescue Exception => e
        reraise_error(e)
      end

      def exec(source, options = {})
        return unless /\S/ =~ source
        @ctx.eval_string("(function(){#{encode(source)}})()", '(execjs)')
      rescue Exception => e
        reraise_error(e)
      end

      def eval(source, options = {})
        return unless /\S/ =~ source
        @ctx.eval_string("(#{encode(source)})", '(execjs)')
      rescue Exception => e
        reraise_error(e)
      end

      def call(identifier, *args)
        @ctx.call_prop(identifier.split("."), *args)
      rescue Exception => e
        reraise_error(e)
      end

      private
        def reraise_error(e)
          case e
          when Duktape::SyntaxError
            raise RuntimeError, e.message
          when Duktape::Error
            raise ProgramError, e.message
          when Duktape::InternalError
            raise RuntimeError, e.message
          else
            raise e
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
