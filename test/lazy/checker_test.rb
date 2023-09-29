require "test_helper"


RECIPE_PATH_ICED = '/Users/philippeperret/Sites/Atelier_Icare/Icare_2023/icare_editions_dev/tests/recipe.yaml'
RECIPE_SANS_NAME = recipe_path('recipe_sans_name')
RECIPE_VALIDE    = recipe_path('recipe_valide')

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
    assert_raises { Lazy::Checker.new }
    assert_silent { Lazy::Checker.new(RECIPE_VALIDE) }
  end

  def test_method_check_exist
    checker = Lazy::Checker.new(RECIPE_VALIDE)
    assert_respond_to checker, :check
  end

  def test_method_data_exist
    checker = Lazy::Checker.new(RECIPE_VALIDE)
    assert_respond_to checker, :data
  end

  def test_site_editions_icare
    checker = Lazy::Checker.new(RECIPE_PATH_ICED)
    assert_silent { checker.check(**{output: false}) }
  end

  # --- Validité de la recette ---

  def test_recette_defines_name
    err = assert_raises(Lazy::Checker::RecipeError) { Lazy::Checker.new(RECIPE_SANS_NAME) }
    assert_equal(Lazy::ERRORS[206], err.message)
  end

  def test_recette_defines_base_valide
    
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


  def test_un_test_complet
    recipe_path = File.join(TEST_FOLDER,'assets','recipe_atelier_icare.yaml')
    checker = nil
    assert_silent { checker = Lazy::Checker.new(recipe_path) }
    out, err = capture_io { checker.check }
    # puts "out : #{out}".bleu
    assert_empty(err)
    assert_match('Success 2 Failures 0', out)
  end

end
