require "test_helper"


class Lazy::TestTest < Minitest::Test

  def setup
    super
  end

  def test_classe_existe
    assert_silent { Lazy::Checker::Test }
  end

  def test_instance_test_repond_a_check
    checker = Object.new
    t = Lazy::Checker::Test.new(checker, {url:'<html></html>', name:"pour voir", checks:[]})
    assert_respond_to( t, :check)
  end
end
