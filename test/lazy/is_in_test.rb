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
    # noko = Nokogiri::HTML(xml)
    noko = Lazy::Checker::Url.new(xml).nokogiri
    i = Lazy::Checker::CheckedTag.new(dtag)
    assert(i.is_in?(noko), TEST_ERRORS[101] % {l:lineno, c: dtag.inspect} + "\n#{i.errors.inspect}")
  end

  def should_fail(xml, dtag, lineno)
    # noko = Nokogiri::HTML(xml)
    noko = Lazy::Checker::Url.new(xml).nokogiri
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
    html = <<~HTML
      <html>
        <head></head>
        <body>
          <div class="mondiv"></div>
          <div class="autre"></div>
        </body>
      </html>
      HTML
    dtag = {tag:'div.mondiv.autre'}
    should_fail(html, dtag, __LINE__)
  end

  def test_div_with_attributes_in
    html = <<~HTML
      <root>
        <div class="mondiv" data-src="la-source"></div>
        <div class="mondiv">Pas vide</div>
      </root>
      HTML
    # Ci-dessous, le empty:false permet de voir si la recherche ne va
    # pas se faire avoir par le div de même classe qui n'est pas vide
    # mais qui ne contient par le bon attribut
    dtag = { tag:'div.mondiv', attrs: {'data-src' => 'la-source'}, empty:false }
    should_fail(html, dtag, __LINE__)
    
    html = <<~HTML
      <root>
        <div id="mondiv" data-src="la-source">Contenu</div>
        <div data-src="la-source">Autre contenu</div>
      </root>
      HTML
    dtag = {tag:'div#mondiv', attrs: {'data-src' => 'la-source'}, empty:false}
    should_succeed(html, dtag, __LINE__)
    dtag = {tag:'div#mondiv', attrs: {'data-src' => 'la-source'}, empty:false, count:2}
    should_fail(html, dtag, __LINE__)
    dtag = {tag:'div#mondiv', attrs: {'data-src' => 'la-source'}, empty:false, count:1}
    should_succeed(html, dtag, __LINE__)
  end

  def test_count
    html = <<~HTML
      <root>
        <div class="bon"></div>
        <div class="bon avec-autre-class"></div>
        <div class="bon">Mais pas vide</div>
        <div class="conteneur">
          <div class="bon mais-dans-conteneur"></div>
        </div>
        <div class="bon avec-autre-class">mais là aussi pas vide</div>
      </root>
      HTML
    dtag = {tag:'div.bon', count:2, empty:true, direct_child:true}
    should_succeed(html,dtag,__LINE__)
  end

  def test_empty
    html = <<~HTML
      <root>
        <div class="bon"></div>
        <div class="autre-class"></div>
        <div>Sans classe pas vide</div>
        <div></div>
        <div>
          <div></div>
        </div>
      </root>
      HTML
    dtag = {tag:'div', count:3, empty:true, direct_child:true}
    should_succeed(html,dtag,__LINE__)
    # Si on les prend tous
    dtag = {tag:'div', count:4, empty:true, direct_child:false}
    should_succeed(html,dtag,__LINE__)
  end

  def test_text_in
    html = '<root><div class="notvide">Contenu</div><div class="notvide"></div></root>'
    dtag = {tag:'div.notvide', text:'Contenu', count:1}
    should_succeed(html, dtag, __LINE__)
  end

  def test_with_attributes
    html = <<~HTML
      <section class="bon">
        <div class="bon" data="out">Il est bon mais out</div>
        <div class="bon" data="in">Il est bon</div>
        <div class="mauvais" data="in">Il est mauvais</div>
        <div class="conteneur">
          <div class="bon" data="in">Il est bon mais dans un conteneur</div>
        </div>
      </section>
      HTML
    dtag = {tag:'div', attrs: {class: 'bon'}, count: 3}
    should_succeed(html, dtag, __LINE__)

    dtag = {tag:'div', attrs: {class: 'bon'}, count: 2, direct_child:true}
    should_succeed(html, dtag, __LINE__)

    dtag = {tag:'div', attrs: {class: 'bon', data: 'in'}, count: 2}
    should_succeed(html, dtag, __LINE__)    

    dtag = {tag:'div', attrs: {class: 'bon', data: 'in'}, count: 1, direct_child:true}
    should_succeed(html, dtag, __LINE__)    
  end

  def test_min_length
    html = <<~HTML
      <root>
        <div class="bon">Contenu trop court</div>
        <div class="bon">Ce contenu est largement assez long.</div>
      </root>
      HTML
    dtag = {tag: 'div.bon', min_length: 20, count: 2}
    should_fail(html, dtag, __LINE__)
    dtag = {tag: 'div.bon', min_length: 20, count: 1}
    should_succeed(html, dtag, __LINE__)    
  end

  def test_max_length
    html = <<~HTML
      <root>
        <div class="bon">Mais ce contenu est trop long</div>
        <div class="bon">Une bonne longueur</div>
      </root>
      HTML
    dtag = {tag: 'div.bon', max_length: 25, count: 1}
    should_succeed(html, dtag, __LINE__)    
  end
end
