#
# Lazy::Checker::Code test
# 
# Lazy::Checker::Code a été implémenté pour pouvoir procéder à un
# test de contenu non pas avec une URL mais avec du code XML 
# directement.
# 
require 'test_helper'

class Lazy::CheckerCodeTest < Minitest::Test

  def setup
    super
  end

  def test_class_exist
    assert_silent { Lazy::Checker::Code }
  end

  def test_une_method_check_generale
    assert_respond_to Lazy::Checker, :check
  end

  def test_method_check_args_validity
    # La méthode Lazy::Checker.check doit recevoir les bons
    # arguments.

    # -- Instanciations invalides --

    err = assert_raises(ArgumentError) { Lazy::Checker.check }
    assert_match("wrong number of arguments (given 0, expected 2)", err.message)

    err = assert_raises(ArgumentError) { Lazy::Checker.check(nil, {}) }
    assert_equal(Lazy::ERRORS[6000] % {se: Lazy::ERRORS[6003]}, err.message)

    err = assert_raises(ArgumentError) { Lazy::Checker.check(12, {}) }
    assert_equal(Lazy::ERRORS[6000] % {se: Lazy::ERRORS[6001] % {c:12.class.name, a: 12.inspect}}, err.message)
  
    code = '<root1></root1><root2></root2>'
    err = assert_raises(ArgumentError) { Lazy::Checker.check(code, {}) }
    assert_equal(Lazy::ERRORS[6000] % {se: Lazy::ERRORS[6002] % {a: code.inspect}}, err.message)

    good_code = '<root><div class="content"></div></root>'
    [
      [ nil,  {se: Lazy::ERRORS[6003]} ],
      [ 12,   {se: Lazy::ERRORS[6011] % {c: 12.class.name, a: 12.inspect}} ],
      [ {bad:true}, {se:Lazy::ERRORS[1002] % {ks: [:bad].pretty_join}}],
    ].each do |bad_check, expected|
      err = assert_raises(ArgumentError) { Lazy::Checker.check(good_code, bad_check)}
      assert_equal(Lazy::ERRORS[6010] % expected, err.message)
    end



    # -- Instanciation valide --

    code = '<root><div></div></root>'
    dcheck = {tag:'div.content', count: 4}
    assert_silent { Lazy::Checker.check(code, dcheck, **{return_result:true})}

    code = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <Racine>
      </Racine>
      XML
    dcheck = {tag:'div.content', count: 4}
    assert_silent { Lazy::Checker.check(code, dcheck, **{return_result:true})}
  
  end

  def test_respond_to_check_against
    inst = Lazy::Checker::Code.new("<root></root>")
    assert_respond_to(inst, :check_against)
  end


end #/Minitest
