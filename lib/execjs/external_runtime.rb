require "json"
require "tempfile"

module ExecJS
  class ExternalRuntime
    def initialize(options)
      @command     = options[:command]
      @runner_path = options[:runner_path]
      @test_args   = options[:test_args]
      @test_match  = options[:test_match]
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
      command = @command.split(/\s+/).first
      binary = `which #{command}`.strip
      if $? == 0
        if @test_args
          output = `#{binary} #{@test_args} 2>&1`
          output.match(@test_match)
        else
          true
        end
      end
    end

    protected
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
        output = `#{@command} #{filename} 2>&1`
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
