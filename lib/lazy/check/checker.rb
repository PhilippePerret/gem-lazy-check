module Lazy
class Checker

  attr_reader :recipe_path

  def initialize(recipe_path = nil)
    recipe_path ||= File.expand_path('.', 'recipe.yaml')
    File.exist?(recipe_path) || raise(ERRORS[200] % {path: recipe_path})
    @recipe_path = recipe_path
  end


  def check
    if proceed_check
      puts "Je suis le checker ultime et j'ai réussi.".vert
    else
      puts "Je suis le checker ultime et j'ai échoué".rouge
    end
  end

  # La méthode (silencieuse) qui produit le check
  def proceed_check
    not(data.nil?)            || raise("Il faudrait des données dans le fichier recette.")
    data.is_a?(Hash)          || raise("Les données devraient être une table.")
    data.key?(:tests)         || raise("Les données devraient définir les tests (:tests)")
    data[:tests].is_a?(Array) || raise("Les données tests (data[:tests]) devraient être une liste (de tests).")
  
    # -- C'est bon, on peut y aller --
    data[:tests].collect do |dtest|
      Test.new(dtest)
    end.each do |test|
      test.check
    end
  end


  def data
    @data ||= YAML.safe_load(File.read(recipe_path), **YAML_OPTIONS)
  end

end #/class Checker
end #/module Lazy
