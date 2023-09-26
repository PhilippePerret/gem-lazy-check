require 'test_helper'

class Lazy::CheckCaseTest < Minitest::Test

  def setup
    super
  end

  def test_classe_exist
    assert_silent { Lazy::Checker::CheckCase }
  end

  def new_url(code)
    Lazy::Checker::Url.new(code)
  end

  def new_case(urler, data_case)
    urler = new_url(urler) if urler.is_a?(String)
    Lazy::Checker::CheckCase.new(urler,data_case)
  end

  def should_fail(check_case)
    assert(check_case.check === false, TEST_ERRORS[100])
  end
  def should_succeed(check_case)
    assert(check_case.check === true, TEST_ERRORS[101])
  end


  def test_check_case_require_good_parameters
    err = assert_raises(ArgumentError) { Lazy::Checker::CheckCase.new }
    expected  = 'wrong number of arguments (given 0, expected 2)'
    actual    = err.message
    assert_equal(expected, actual, TEST_ERRORS[10] % {e: expected.strip, a:actual.strip})
  
    err = assert_raises(ArgumentError) { Lazy::Checker::CheckCase.new(nil, nil) }
    expected = (ERRORS[1000] % {a:nil, c:NilClass}).strip
    actual   = err.message.strip
    assert_equal(expected, actual, TEST_ERRORS[10] % {e: expected.strip, a:actual.strip})

    err = assert_raises(ArgumentError) { Lazy::Checker::CheckCase.new(22, nil) }
    expected = (ERRORS[1000] % {a:22, c:22.class.name}).strip
    actual   = err.message.strip
    assert_equal(expected, actual, TEST_ERRORS[10] % {e: expected.strip, a:actual.strip})

    urler = Lazy::Checker::Url.new('https://google.com')
    err = assert_raises(ArgumentError) { Lazy::Checker::CheckCase.new(urler, nil) }
    expected = (ERRORS[1001] % {a:nil, c:NilClass}).strip
    actual   = err.message.strip
    assert_equal(expected, actual, TEST_ERRORS[10] % {e: expected.strip, a:actual.strip})

    urler = Lazy::Checker::Url.new('https://google.com')
    err = assert_raises(ArgumentError) { Lazy::Checker::CheckCase.new(urler, 12) }
    expected = (ERRORS[1001] % {a:12, c:12.class.name}).strip
    actual   = err.message.strip
    assert_equal(expected, actual, TEST_ERRORS[10] % {e: expected.strip, a:actual.strip})

    # -- Mauvaises data ---

    err = assert_raises(ArgumentError) { Lazy::Checker::CheckCase.new(urler, {empty: true})}
    expected = (ERRORS[1002] % {ks:':' + {empty:true}.keys.join(', :')}).strip
    actual   = err.message.strip
    assert_equal(expected, actual, TEST_ERRORS[10] % {e: expected.strip, a:actual.strip})    

    err = assert_raises(ArgumentError) { Lazy::Checker::CheckCase.new(urler, {tag:'div', empty: true})}
    expected = (ERRORS[1003] % {a: 'div'}).strip
    actual   = err.message.strip
    assert_equal(expected, actual, TEST_ERRORS[10] % {e: expected.strip, a:actual.strip})    
  
  end


  def test_checkcase_respond_to_check
    urler = Lazy::Checker::Url.new('https://google.com')
    ccase = Lazy::Checker::CheckCase.new(urler, {tag:'div.essai', empty:true})
    assert_respond_to ccase, :check
  end

  def test_check_retour_true_if_succes
    urler = Lazy::Checker::Url.new('<div class="essai hidden"> </div>')
    ccase = Lazy::Checker::CheckCase.new(urler, {tag:'div.essai.hidden', empty:true})
    res = ccase.check
    assert(res === true, TEST_ERRORS[101])

    urler = Lazy::Checker::Url.new('<div class="essai"></div>')
    ccase = Lazy::Checker::CheckCase.new(urler, {tag:'div.essai', empty:true})
    assert(ccase.check === true, TEST_ERRORS[101])
  end


  def test_check_retour_false_if_failure
    urler = new_url('<div class="essai"><span></span></div>')
    ccase = new_case(urler, {tag:'div.essai', empty:true})
    assert(ccase.check === false, TEST_ERRORS[100])
  end


  def test_check_case_count_is_right
    # Test du paramètre :only (avec un nombre)
    urler = new_url('<html><section><div class="grand"></div><div class="grand"></div></section></html>')
    dcase = {tag:'div.grand', count: 2}
    should_succeed(new_case(urler, dcase))

    dcase = {tag:'div.grand', count: 3}
    should_fail(new_case(urler, dcase))

  end

end
