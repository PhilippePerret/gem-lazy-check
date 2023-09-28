#
# Grande feuille de test permettant de tester en profondeur
# la méthode principale CheckedTag#is_in? qui permet de savoir
# si un noeud se trouve dans un contenant tel que ce contenu est
# décrit.
# 
require 'test_helper'

class Lazy::IsInTest < Minitest::Test

  def setup
    super
  end

  def should_succeed(xml, dtag, lineno)
    noko = Nokogiri::HTML(xml)
    i = Lazy::Checker::CheckedTag.new(dtag)
    assert(i.is_in?(noko), TEST_ERRORS[101] % {l:lineno, c: dtag.inspect} + "\n#{i.errors.inspect}")
  end

  def should_fail(xml, dtag, lineno)
    noko = Nokogiri::HTML(xml)
    i = Lazy::Checker::CheckedTag.new(dtag)
    refute(i.is_in?(noko), TEST_ERRORS[100] % {l:lineno, c: dtag.inspect} + "\n#{i.errors.inspect}")
  end

  # --- Tous les tests de tests ---

  def test_div_with_id_in
    html = '<html><head></head><body><div id="mondiv"></div></body></html>'
    dtag = {tag:'div#mondiv'}
    should_succeed(html, dtag, __LINE__)
  end

  def test_div_with_id_out
    xml  = '<html><head></head><body></body></html>'
    dtag = {tag:'div#mondiv'}
    should_fail(xml, dtag, __LINE__)
  end

  def test_div_with_class_in
    html = '<html><head></head><body><div class="mondiv"></div></body></html>'
    dtag = {tag:'div.mondiv'}
    should_succeed(html, dtag, __LINE__)
  end

  def test_div_with_plusieurs_class_in
    html = '<html><head></head><body><div class="mondiv autre"></div><div class="autre"></div></body></html>'
    dtag = {tag:'div.autre.mondiv', count: 1}
    should_succeed(html, dtag, __LINE__)    

    html = '<html><head></head><body><div class="mondiv"></div><div class="autre"></div><div class="mondiv autre"></div></body></html>'
    dtag = {tag:'div.mondiv.autre', count: 1}
    should_succeed(html, dtag, __LINE__)
  end

  def test_div_with_class_out
    html = '<html><head></head><body><div class="mondiv-autre"></div></body></html>'
    dtag = {tag:'div.mondiv'}
    should_fail(html, dtag, __LINE__)
  end

  def test_div_with_plusieurs_class_out
    # si on cherche plusieurs classes css pour un div, que plusieurs
    # div les contiennent, mais pas tous, ça ne renvoie rien.
    html = '<html><head></head><body><div class="mondiv"></div><div class="autre"></div></body></html>'
    dtag = {tag:'div.mondiv.autre'}
    should_fail(html, dtag, __LINE__)
  end

  def test_div_with_attributes_in
    html = '<root><div class="mondiv" data-src="la-source"></div><div class="mondiv">Pas vide</div></root>'
    # Ci-dessous, le empty:false permet de voir si la recherche ne va
    # pas se faire avoir par le div de même classe qui n'est pas vide
    # mais qui ne contient par le bon attribut
    dtag = { tag:'div.mondiv', attrs: {'data-src' => 'la-source'}, empty:false }
    should_fail(html, dtag, __LINE__)
    
    html = '<root><div id="mondiv" data-src="la-source">Contenu</div></root>'
    dtag = {tag:'div#mondiv', attrs: {'data-src' => 'la-source'}, empty:false}
    should_succeed(html, dtag, __LINE__)
  end

  def test_count
    
  end

  def test_empty
    
  end

  def test_text_in
    html = '<root><div class="notvide">Contenu</div><div class="notvide"></div></root>'
    dtag = {tag:'div.notvide', text:'Contenu', count:1}
    should_succeed(html, dtag, __LINE__)
  end

end
