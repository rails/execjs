require "execjs"
require "test/unit"

class TestExecJS < Test::Unit::TestCase
  def test_exec
    assert_equal true, ExecJS.exec("return true")
  end

  def test_eval
    assert_equal ["red", "yellow", "blue"], ExecJS.eval("'red yellow blue'.split(' ')")
  end

  def test_runtime_available
    runtime = ExecJS::ExternalRuntime.new(:command => "nonexistent")
    assert !runtime.available?

    runtime = ExecJS::ExternalRuntime.new(:command => "ruby")
    assert runtime.available?
  end

  def test_compile
    context = ExecJS.compile("foo = function() { return \"bar\"; }")
    assert_equal "bar", context.exec("return foo()")
    assert_equal "bar", context.eval("foo()")
  end

  def test_pure_evaluation
    context = ExecJS.compile("foo = function() { return \"bar\"; }")
    assert_equal "bar", context.eval("foo()", :pure => true)
  end

  def test_context_call
    context = ExecJS.compile("id = function(v) { return v; }")
    assert_equal "bar", context.call("id", "bar")
  end

  def test_nested_context_call
    context = ExecJS.compile("a = {}; a.b = {}; a.b.id = function(v) { return v; }")
    assert_equal "bar", context.call("a.b.id", "bar")
  end

  def test_context_call_missing_function
    context = ExecJS.compile("")
    assert_raises ExecJS::ProgramError do
      context.call("missing")
    end
  end
end
