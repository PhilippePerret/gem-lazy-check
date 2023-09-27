#
# Test de la class Lazy::Checker::CheckedTag
# 
# Cette classe reçoit la définition d'une "tag" (par exemple
# {tag: "mon#div", count: 3, contains:"bonjour"}) et retourne une
# instance qui facilite les checks
# 
require 'test_helper'

class Lazy::CheckerCheckedTagTest < Minitest::Test

  def setup
    super
  end

  def test_classe_exists
    assert_silent { Lazy::Checker::CheckedTag }
  end

  def test_responding_methods
    i = Lazy::Checker::CheckedTag.new({tag:'div#mondiv'})
    assert_respond_to i, :is_in?
  end

  def test_is_in_succeed
    i = Lazy::Checker::CheckedTag.new({tag:'div#mondiv'})
    noko = Nokogiri::HTML('<html><head></head><body></body></html>')
    i.is_in?(noko)
  end


end
