require "test_helper"

RECIPE_PATH_ICED = '/Users/philippeperret/Sites/Atelier_Icare/Icare_2023/icare_editions_dev/tests/recipe.yaml'

class Lazy::CheckTest < Minitest::Test

  def setup
    super
  end

  def path_to_recipe
    @path_to_recipe ||= File.join(__dir__,'recipe.yaml')
  end

  def test_that_it_has_a_version_number
    refute_nil ::Lazy::Check::VERSION
  end

  def test_instanciation
    assert_silent { Lazy::Checker.new }
    assert_silent { Lazy::Checker.new(path_to_recipe) }
  end

  def test_method_check_exist
    checker = Lazy::Checker.new
    assert_respond_to checker, :check
  end

  def test_method_data_exist
    checker = Lazy::Checker.new
    assert_respond_to checker, :data
  end

  def test_site_editions_icare
    checker = Lazy::Checker.new(RECIPE_PATH_ICED)
    # puts "data = #{checker.data.inspect}"
    assert_silent { checker.proceed_check }
  end

  def test_donnees_non_table_echoue
    # La recette doit être une table
  end

  def test_donnees_sans_cle_tests_echoue
    # La recette doit définir la clé :tests
  end

  def test_donnees_tests_doivent_etre_une_liste
    # data[:tests] doit être une liste
  end

end
