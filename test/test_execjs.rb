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
end
