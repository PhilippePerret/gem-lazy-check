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

  # Finalement, petit à petit, on vient à donner à cette
  # méthode ultime le code de la page (check_case::String) et
  # les données du Case.
  # Mais à l'origine, elle ne recevait qu'un CheckCase
  def should_succeed(check_case, data_case = nil, linenum)
    check_case = ensure_check_case(check_case, data_case)
    assert(check_case.check === true, TEST_ERRORS[101] % {c: data_case.inspect, l:linenum})
  end
  # @idem que la précédente
  def should_fail(check_case, data_case = nil, linenum)
    check_case = ensure_check_case(check_case, data_case)
    assert(check_case.check === false, TEST_ERRORS[100] % {c: data_case.inspect, l:linenum})
  end

  def ensure_check_case(check_case, data_case)
    if check_case.is_a?(String)
      urler = new_url(check_case)
      check_case = new_case(urler, data_case)
    else
      return check_case
    end
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

    # Attention, à partir d'ici, c'est CheckedTag qu'on test (refactorisation required)

    err = assert_raises(ArgumentError) { Lazy::Checker::CheckedTag.new({tag:'div', empty: true})}
    expected = (ERRORS[1003] % {a: 'div'}).strip
    actual   = err.message.strip
    assert_equal(expected, actual, TEST_ERRORS[10] % {e: expected.strip, a:actual.strip})
    
    err = assert_raises(ArgumentError) { Lazy::Checker::CheckedTag.new({tag:'div.content', count: "Faux"})}
    expected  = (ERRORS[1004] % {a: "Faux".inspect, c: "Faux".class.name}).strip
    actual    = err.message.strip
    assert_equal(expected, actual, TEST_ERRORS[10] % {e: expected, a:actual})
  end


  def test_checkcase_respond_to_check
    urler = Lazy::Checker::Url.new('https://google.com')
    ccase = Lazy::Checker::CheckCase.new(urler, {tag:'div.essai', empty:true})
    assert_respond_to ccase, :check
  end

  def test_check_retour_true_if_success
    code = '<div class="essai hidden"> </div>'
    dcas = {tag:'div.essai.hidden', empty:true}
    should_succeed(code, dcas, __LINE__)

    code = '<div class="essai"></div>'
    dcas = {tag:'div.essai', empty:true}
    should_succeed(code, dcas, __LINE__)
  end


  def test_check_retour_false_if_failure
    code = '<div class="essai"><span></span></div>'
    should_fail(code, {tag:'div.essai', empty:true}, __LINE__)
    should_succeed(code, {tag:'div.essai', notext: true}, __LINE__)
  end

  # Paramètre :count
  def test_check_case_count_is_right
    # Test du paramètre :count (avec un nombre). On doit trouver 
    # exactement le nombre d'éléments spécifiés dans la page
    urler = new_url('<html><section><div class="grand"></div><div class="grand"></div></section></html>')
    dcase = {tag:'div.grand', count: 2}
    should_succeed(new_case(urler, dcase), nil, __LINE__)

    dcase = {tag:'div.grand', count: 3}
    should_fail(new_case(urler, dcase), nil, __LINE__)
  end

  # Paramètre :empty
  # 
  # Si on précise 'empty: true' dans la recette, alors l'élément doit être
  # vide. Si on précise 'empty: false' alors il ne doit surtout pas être
  # vide.
  def test_check_case_empty_is_right
    code = '<div class="vide"></div>'
    dcase = {tag:'div.vide', empty:true}
    should_succeed(code, dcase, __LINE__)

    code = '<div class="pasvide"><span></span></div>'
    dcase = {tag:'div.pasvide', empty:true}
    should_fail(code, dcase, __LINE__)

    code = '<div class="vide"></div>'
    dcase = {tag:'div.vide', empty:false}
    should_fail(code, dcase, __LINE__)
  end

  # Paramètre :contains
  # 
  # Si on précise du contenu, on doit le trouver dans la balise
  # spécifiée. Par exemple, en mettant < contains: 'div.vide' > on
  # doit trouver un div de classe css "vide"
  # 
  # :contains peut être :
  #   - un string (un texte à contenir)
  #   - une balise avec classe et/ou identifiant
  #   - une table contenant :tag, :count, etc. comme un node normal
  #   - une liste de l'un de ces trucs
  #
  def test_check_case_contains


    code  = '<div id="pasvide">Bonjour</div>'
    dcase = {tag: 'div#pasvide', contains:'Bonjour'}
    should_succeed(code, dcase, __LINE__)
    # Ça peut être contenu dans un sous-élément
    code  = '<div id="pasvide"><span class="autre">Bonjour</span></div>'
    should_succeed(code, dcase, __LINE__)
    # peut être contenu en un seul mot dans deux sous-élément
    code  = '<div id="pasvide"><span class="autre">Bon<span>jour</span></span></div>'
    should_succeed(code, dcase, __LINE__)
    code  = '<div id="pasvide">Bonjour</div>'
    dcase = {tag: 'div#pasvide', contains:['Bon','jour']}
    should_succeed(code, dcase, __LINE__)
    # Ça peut être contenu dans un sous-élément
    code  = '<div id="pasvide">Bon<span>jour</span></div>'
    should_succeed(code, dcase, __LINE__)


    code  = '<div id="pasvide">Bonjour</div>'
    dcase = {tag: 'div#pasvide', contains:'Au revoir'}
    should_fail(code, dcase, __LINE__)
    # Il doit contenir tous les mots définis
    dcase = {tag: 'div#pasvide', contains:['Bonjour', 'Au revoir']}
    should_fail(code, dcase, __LINE__)

    code = '<div class="vide"></div>'
    dcase = {tag: 'div.vide', contains: 'div.contenu'}
    should_fail(code, dcase, __LINE__)

    # -> celui-là
    code = '<div class="contient"><div id="dedans"></div></div>'
    dcase = {tag: 'div.contient', contains: 'div#dedans'}
    should_succeed(code, dcase, __LINE__)

    # -- le bon nombre -
    code = '<div class="contient"><div class="in"></div><div class="in"></div></div>'
    dcase = {tag: 'div.contient', contains:'div.in'}
    should_succeed(code, dcase, __LINE__)
    dcase = {tag: 'div.contient', contains:{tag:'div.in', count:2}}
    should_succeed(code, dcase, __LINE__)
    dcase = {tag: 'div.contient', contains:{tag:'div.in', count:3}}
    should_fail(code, dcase, __LINE__)

    # -- Même imbriqués --
  
  end

  def test_divs_imbriqued
    # Si on cherche deux éléments de même classe, mais qu'ils sont
    # imbriqués, on doit produire un succès
    code = '<div class="contient"><div class="in"><div class="in"></div></div></div>'
    dcase = {tag:'div.contient', contains:{tag:'div.in', count:2}}
    should_succeed(code, dcase, __LINE__)
    # L'affirmation précédente est vrai SAUF si :direct_child_only
    # est à true
    code = '<div class="contient"><div class="in"><div class="in"></div></div></div>'
    dcase = {tag:'div.contient', contains:{tag:'div.in', count:2, direct_child_only: true}}
    should_fail(code, dcase, __LINE__)
  end

  def test_ignore_elements_around
    # -- Ne doit pas compter les éléments autour --
    code = '<root><div class="in"></div> <div class="in"><div class="contient"><div class="in"><div class="in"></div></div></div></div></root>'
    dcas = {tag:'div.contient', contains:{tag:'div.in', count:2}}
    should_succeed(code, dcas, __LINE__)
  end

end
