# -*- coding: utf-8 -*-
require "minitest/autorun"
require "execjs/module"
require "json"

begin
  require "execjs"
rescue ExecJS::RuntimeUnavailable => e
  warn e
  exit 2
end

if defined? Minitest::Test
  Test = Minitest::Test
elsif defined? MiniTest::Unit::TestCase
  Test = MiniTest::Unit::TestCase
end

class TestExecJS < Test
  def test_runtime_available
    runtime = ExecJS::ExternalRuntime.new(command: "nonexistent")
    assert !runtime.available?

    runtime = ExecJS::ExternalRuntime.new(command: "ruby")
    assert runtime.available?
  end

  def test_runtime_assignment
    original_runtime = ExecJS.runtime
    runtime = ExecJS::ExternalRuntime.new(command: "nonexistent")
    assert_raises(ExecJS::RuntimeUnavailable) { ExecJS.runtime = runtime }
    assert_equal original_runtime, ExecJS.runtime

    runtime = ExecJS::ExternalRuntime.new(command: "ruby")
    ExecJS.runtime = runtime
    assert_equal runtime, ExecJS.runtime
  ensure
    ExecJS.runtime = original_runtime
  end

  def test_context_call
    context = ExecJS.compile("id = function(v) { return v; }")
    assert_equal "bar", context.call("id", "bar")
  end

  def test_nested_context_call
    context = ExecJS.compile("a = {}; a.b = {}; a.b.id = function(v) { return v; }")
    assert_equal "bar", context.call("a.b.id", "bar")
  end

  def test_call_with_complex_properties
    context = ExecJS.compile("")
    assert_equal 2, context.call("function(a, b) { return a + b }", 1, 1)

    context = ExecJS.compile("foo = 1")
    assert_equal 2, context.call("(function(bar) { return foo + bar })", 1)
  end

  def test_call_with_this
    # Known bug: https://github.com/cowboyd/therubyrhino/issues/39
    skip if ExecJS.runtime.is_a?(ExecJS::RubyRhinoRuntime)

    # Make sure that `this` is indeed the global scope
    context = ExecJS.compile(<<-EOF)
      name = 123;

      function Person(name) {
        this.name = name;
      }

      Person.prototype.getThis = function() {
        return this.name;
      }
    EOF

    assert_equal 123, context.call("(new Person('Bob')).getThis")
  end

  def test_context_call_missing_function
    context = ExecJS.compile("")
    assert_raises ExecJS::ProgramError do
      context.call("missing")
    end
  end

  {
    "function() {}" => nil,
    "0" => 0,
    "null" => nil,
    "undefined" => nil,
    "true" => true,
    "false" => false,
    "[1, 2]" => [1, 2],
    "[1, function() {}]" => [1, nil],
    "'hello'" => "hello",
    "'red yellow blue'.split(' ')" => ["red", "yellow", "blue"],
    "{a:1,b:2}" => {"a"=>1,"b"=>2},
    "{a:true,b:function (){}}" => {"a"=>true},
    "'café'" => "café",
    '"☃"' => "☃",
    '"\u2603"' => "☃",
    "'\u{1f604}'".encode("UTF-8") => "\u{1f604}".encode("UTF-8"), # Smiling emoji
    "'\u{1f1fa}\u{1f1f8}'".encode("UTF-8") => "\u{1f1fa}\u{1f1f8}".encode("UTF-8"), # US flag
    '"\\\\"' => "\\"
  }.each_with_index do |(input, output), index|
    define_method("test_exec_string_#{index}") do
      assert_output output, ExecJS.exec("return #{input}")
    end

    define_method("test_eval_string_#{index}") do
      assert_output output, ExecJS.eval(input)
    end

    define_method("test_compile_return_string_#{index}") do
      context = ExecJS.compile("var a = #{input};")
      assert_output output, context.eval("a")
    end

    define_method("test_compile_call_string_#{index}") do
      context = ExecJS.compile("function a() { return #{input}; }")
      assert_output output, context.call("a")
    end
  end

  [
    nil,
    true,
    false,
    1,
    3.14,
    "hello",
    "\\",
    "café",
    "☃",
    "\u{1f604}".encode("UTF-8"), # Smiling emoji
    "\u{1f1fa}\u{1f1f8}".encode("UTF-8"), # US flag
    [1, 2, 3],
    [1, [2, 3]],
    [1, [2, [3]]],
    ["red", "yellow", "blue"],
    { "a" => 1, "b" => 2},
    { "a" => 1, "b" => [2, 3]},
    { "a" => true }
  ].each_with_index do |value, index|
    json_value = JSON.generate(value, quirks_mode: true)

    define_method("test_json_value_#{index}") do
      assert_output value, JSON.parse(json_value, quirks_mode: true)
    end

    define_method("test_exec_value_#{index}") do
      assert_output value, ExecJS.exec("return #{json_value}")
    end

    define_method("test_eval_value_#{index}") do
      assert_output value, ExecJS.eval("#{json_value}")
    end

    define_method("test_strinigfy_value_#{index}") do
      context = ExecJS.compile("function json(obj) { return JSON.stringify(obj); }")
      assert_output json_value, context.call("json", value)
    end

    define_method("test_call_value_#{index}") do
      context = ExecJS.compile("function id(obj) { return obj; }")
      assert_output value, context.call("id", value)
    end
  end

  def test_additional_options
    assert ExecJS.eval("true", :foo => true)
    assert ExecJS.exec("return true", :foo => true)

    context = ExecJS.compile("foo = true", :foo => true)
    assert context.eval("foo", :foo => true)
    assert context.exec("return foo", :foo => true)
  end

  def test_eval_blank
    assert_nil ExecJS.eval("")
    assert_nil ExecJS.eval(" ")
    assert_nil ExecJS.eval("  ")
  end

  def test_exec_return
    assert_nil ExecJS.exec("return")
  end

  def test_exec_no_return
    assert_nil ExecJS.exec("1")
  end

  def test_encoding
    utf8 = Encoding.find('UTF-8')

    assert_equal utf8, ExecJS.exec("return 'hello'").encoding
    assert_equal utf8, ExecJS.eval("'☃'").encoding

    ascii = "'hello'".encode('US-ASCII')
    result = ExecJS.eval(ascii)
    assert_equal "hello", result
    assert_equal utf8, result.encoding

    assert_raises Encoding::UndefinedConversionError do
      binary = "\xde\xad\xbe\xef".force_encoding("BINARY")
      ExecJS.eval(binary)
    end
  end

  def test_encoding_compile
    utf8 = Encoding.find('UTF-8')

    context = ExecJS.compile("foo = function(v) { return '¶' + v; }".encode("ISO8859-15"))

    assert_equal utf8, context.exec("return foo('hello')").encoding
    assert_equal utf8, context.eval("foo('☃')").encoding

    ascii = "foo('hello')".encode('US-ASCII')
    result = context.eval(ascii)
    assert_equal "¶hello", result
    assert_equal utf8, result.encoding

    assert_raises Encoding::UndefinedConversionError do
      binary = "\xde\xad\xbe\xef".force_encoding("BINARY")
      context.eval(binary)
    end
  end

  def test_surrogate_pairs
    # Smiling emoji
    str = "\u{1f604}".encode("UTF-8")
    assert_equal 2, ExecJS.eval("'#{str}'.length")
    assert_equal str, ExecJS.eval("'#{str}'")

    # US flag emoji
    str = "\u{1f1fa}\u{1f1f8}".encode("UTF-8")
    assert_equal 4, ExecJS.eval("'#{str}'.length")
    assert_equal str, ExecJS.eval("'#{str}'")
  end

  def test_compile_anonymous_function
    context = ExecJS.compile("foo = function() { return \"bar\"; }")
    assert_equal "bar", context.exec("return foo()")
    assert_equal "bar", context.eval("foo()")
    assert_equal "bar", context.call("foo")
  end

  def test_compile_named_function
    context = ExecJS.compile("function foo() { return \"bar\"; }")
    assert_equal "bar", context.exec("return foo()")
    assert_equal "bar", context.eval("foo()")
    assert_equal "bar", context.call("foo")
  end

  def test_this_is_global_scope
    assert_equal true, ExecJS.eval("this === (function() {return this})()")
    assert_equal true, ExecJS.exec("return this === (function() {return this})()")
  end

  def test_browser_self_is_undefined
    assert ExecJS.eval("typeof self == 'undefined'")
  end

  def test_node_global_is_undefined
    assert ExecJS.eval("typeof global == 'undefined'")
  end

  def test_node_process_is_undefined
    assert ExecJS.eval("typeof process == 'undefined'")
    refute ExecJS.eval("'process' in this")
  end

  def test_commonjs_vars_are_undefined
    assert ExecJS.eval("typeof module == 'undefined'")
    assert ExecJS.eval("typeof exports == 'undefined'")
    assert ExecJS.eval("typeof require == 'undefined'")

    refute ExecJS.eval("'module' in this")
    refute ExecJS.eval("'exports' in this")
    refute ExecJS.eval("'require' in this")
  end

  def test_console_is_undefined
    assert ExecJS.eval("typeof console == 'undefined'")
    refute ExecJS.eval("'console' in this")
  end

  def test_timers_are_undefined
    assert ExecJS.eval("typeof setTimeout == 'undefined'")
    assert ExecJS.eval("typeof setInterval == 'undefined'")
    assert ExecJS.eval("typeof clearTimeout == 'undefined'")
    assert ExecJS.eval("typeof clearInterval == 'undefined'")
    assert ExecJS.eval("typeof setImmediate == 'undefined'")
    assert ExecJS.eval("typeof clearImmediate == 'undefined'")

    refute ExecJS.eval("'setTimeout' in this")
    refute ExecJS.eval("'setInterval' in this")
    refute ExecJS.eval("'clearTimeout' in this")
    refute ExecJS.eval("'clearInterval' in this")
    refute ExecJS.eval("'setImmediate' in this")
    refute ExecJS.eval("'clearImmediate' in this")
  end

  def test_compile_large_scripts
    body = "var foo = 'bar';\n" * 100_000
    assert ExecJS.exec("function foo() {\n#{body}\n};\nreturn true")
  end

  def test_large_return_value
    string = ExecJS.eval('(new Array(100001)).join("abcdef")')
    assert_equal 600_000, string.size
  end

  def test_exec_syntax_error
    begin
      ExecJS.exec(")")
      flunk
    rescue ExecJS::RuntimeError => e
      assert e
      assert e.backtrace[0].include?("(execjs):1"), e.backtrace.join("\n")
    end
  end

  def test_eval_syntax_error
    begin
      ExecJS.eval(")")
      flunk
    rescue ExecJS::RuntimeError => e
      assert e
      assert e.backtrace[0].include?("(execjs):1"), e.backtrace.join("\n")
    end
  end

  def test_compile_syntax_error
    begin
      ExecJS.compile(")")
      flunk
    rescue ExecJS::RuntimeError => e
      assert e
      assert e.backtrace[0].include?("(execjs):1"), e.backtrace.join("\n")
    end
  end

  def test_exec_thrown_error
    begin
      ExecJS.exec("throw new Error('hello')")
      flunk
    rescue ExecJS::ProgramError => e
      assert e
      assert e.backtrace[0].include?("(execjs):1"), e.backtrace.join("\n")
    end
  end

  def test_eval_thrown_error
    begin
      ExecJS.eval("(function(){ throw new Error('hello') })()")
      flunk
    rescue ExecJS::ProgramError => e
      assert e
      assert e.backtrace[0].include?("(execjs):1"), e.backtrace.join("\n")
    end
  end

  def test_compile_thrown_error
    begin
      ExecJS.compile("throw new Error('hello')")
      flunk
    rescue ExecJS::ProgramError => e
      assert e
      assert e.backtrace[0].include?("(execjs):1"), e.backtrace.join("\n")
    end
  end

  def test_exec_thrown_string
    assert_raises ExecJS::ProgramError do
      ExecJS.exec("throw 'hello'")
    end
  end

  def test_eval_thrown_string
    assert_raises ExecJS::ProgramError do
      ExecJS.eval("(function(){ throw 'hello' })()")
    end
  end

  def test_compile_thrown_string
    assert_raises ExecJS::ProgramError do
      ExecJS.compile("throw 'hello'")
    end
  end

  def test_babel
    skip if ExecJS.runtime.is_a?(ExecJS::RubyRhinoRuntime)

    assert source = File.read(File.expand_path("../fixtures/babel.js", __FILE__))
    source = <<-JS
      var self = this;
      #{source}
      babel.eval = function(code) {
        return eval(babel.transform(code)["code"]);
      }
    JS
    context = ExecJS.compile(source)
    assert_equal 64, context.call("babel.eval", "((x) => x * x)(8)")
  end

  def test_coffeescript
    assert source = File.read(File.expand_path("../fixtures/coffee-script.js", __FILE__))
    context = ExecJS.compile(source)
    assert_equal 64, context.call("CoffeeScript.eval", "((x) -> x * x)(8)")
  end

  def test_uglify
    assert source = File.read(File.expand_path("../fixtures/uglify.js", __FILE__))
    source = <<-JS
      #{source}

      function uglify(source) {
        var ast = UglifyJS.parse(source);
        var stream = UglifyJS.OutputStream();
        ast.print(stream);
        return stream.toString();
      }
    JS
    context = ExecJS.compile(source)
    assert_equal "function foo(bar){return bar}",
      context.call("uglify", "function foo(bar) {\n  return bar;\n}")
  end

  private

    def assert_output(expected, actual)
      if expected.nil?
        assert_nil actual
      else
        assert_equal expected, actual
      end
    end
end
