require "json"
require "tempfile"

module ExecJS
  class ExternalRuntime
    def initialize(options)
      @command     = options[:command]
      @runner_path = options[:runner_path]
      @test_args   = options[:test_args]
      @test_match  = options[:test_match]
      @conversion  = options[:conversion]
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
          name = name.split(/\s+/).first
          result = if ExecJS.windows?
            `#{ExecJS.root}/support/which.bat #{name}`
          else
            `which #{name} 2>&1`
          end
          result.strip.split("\n").first
        end
      end

      def compile(source)
        runner_source.dup.tap do |output|
          output.sub!('#{source}', source)
          output.sub!('#{json2_source}') do
            IO.read(ExecJS.root + "/support/json2.js")
          end
        end
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
        output = sh("#{@binary} #{filename} 2>&1")
        if $?.success?
          output
        else
          raise RuntimeError, output
        end
      end

      if "".respond_to?(:force_encoding)
        def sh(command)
          output, options = nil, {}
          options[:internal_encoding] = @conversion[:from] if @conversion
          IO.popen(command, options) { |f| output = f.read }
          output.force_encoding(@conversion[:to]) if @conversion
          output
        end
      else
        require "iconv"

        def sh(command)
          output = nil
          IO.popen(command) { |f| output = f.read }

          if @conversion
            Iconv.iconv(@conversion[:from], @conversion[:to], output).first
          else
            output
          end
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
