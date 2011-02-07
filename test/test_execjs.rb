require "execjs"
require "test/unit"

class TestExecJS < Test::Unit::TestCase
  def test_exec
    assert_equal true, ExecJS.exec("return true")
  end

  def test_eval
    assert_equal ["red", "yellow", "blue"], ExecJS.eval("'red yellow blue'.split(' ')")
  end
end
