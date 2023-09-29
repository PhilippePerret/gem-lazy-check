require 'test_helper'

class Lazy::UrlTest < Minitest::Test

  def setup
    super
  end

  def test_classe_exist
    assert_silent { Lazy::Checker::Url }
  end

  def test_peut_lire_une_url
    url = Lazy::Checker::Url.new("https://www.atelier-icare.net")
    assert_respond_to(url, :readit)
    assert_respond_to(url, :code_html)
    assert_respond_to(url, :nokogiri)
  end

  def test_http_response
    urler = Lazy::Checker::Url.new('https://mauvais.dommaine.com')
    assert_instance_of(Lazy::Checker::Url, urler)
    urler.readit
    assert_equal(443, urler.rvalue)
  end

  def test_redirection
    checker = Lazy::Checker.new(recipe_path('recipe_redirection'))
    out, _ = capture_io { checker.check }
    assert_match('Success 1 Failures 0', out)
    assert_match('La page mon_profil.html redirige vers mon profil', out)
  end

  def test_response
    checker = Lazy::Checker.new(recipe_path('recipe_response_404'))
    out, _ = capture_io { checker.check }
    assert_match('Success 1 Failures 0', out)
    assert_match('La page https://www.atelier-icare.net/page-inexistante.html n\'existe pas', out)
  end
end
