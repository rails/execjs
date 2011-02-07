require "json"
require "tempfile"

module ExecJS
  class ExternalRuntime
    def initialize(options)
      @command     = options[:command]
      @runner_path = options[:runner_path]
      @test_args   = options[:test_args]
      @test_match  = options[:test_match]
      @binary      = locate_binary
    end

    def eval(source)
      if /\S/ =~ source
        exec("return eval(#{"(#{source})".to_json})")
      end
    end

    def exec(source)
      compile_to_tempfile(source) do |file|
        extract_result(exec_runtime(file.path))
      end
    end

    def available?
      @binary ? true : false
    end

    protected
      def locate_binary
        if binary = which(@command)
          if @test_args
            output = `#{binary} #{@test_args} 2>&1`
            binary if output.match(@test_match)
          else
            binary
          end
        end
      end

      def which(command)
        Array(command).find do |name|
          result = if ExecJS.windows?
            `#{ExecJS.root}/support/which.bat #{name}`
          else
            `which #{name} 2>&1`
          end
          result.strip.split("\n").first
        end
      end

      def compile(source)
        runner_source.sub('#{source}', source)
      end

      def runner_source
        @runner_source ||= IO.read(@runner_path)
      end

      def compile_to_tempfile(source)
        tempfile = Tempfile.open("execjs")
        tempfile.write compile(source)
        tempfile.close
        yield tempfile
      ensure
        tempfile.close!
      end

      def exec_runtime(filename)
        output = `#{@binary} #{filename} 2>&1`
        if $?.success?
          output
        else
          raise RuntimeError, output
        end
      end

      def extract_result(output)
        status, value = output.empty? ? [] : JSON.parse(output)
        if status == "ok"
          value
        else
          raise ProgramError, value
        end
      end
  end
end
