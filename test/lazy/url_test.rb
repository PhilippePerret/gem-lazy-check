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
    assert_respond_to(url, :read)
    assert_respond_to(url, :code_html)
    assert_respond_to(url, :nokogiri)
  end

end
