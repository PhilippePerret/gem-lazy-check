#
# Test en réel, avec l'atelier icare
# 
# Toutes les pages à tester se trouve dans le dossier test/lazy_checker de
# l'atelier.
# 
require 'test_helper'

class Lazy::TestIcare < Minitest::Test

  def setup
    super
  end

  def test_icare
    checker = Lazy::Checker.new(recipe_path('recipe_with_icare'))
    out, err = capture_io { checker.check }
    puts "<<<<<<<<<<<<\n#{out}\n>>>>>>>>>>>>>>>>"
    assert_empty(err)
    assert_match(/Échecs 0/, out)

  end

end
