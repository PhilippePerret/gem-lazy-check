module Lazy
class Checker

  class RecipeError < StandardError; end

  attr_reader :recipe_path

  attr_reader :reporter

  attr_reader :options

  def initialize(recipe_path = nil)
    recipe_path ||= File.expand_path('.', 'recipe.yaml')
    File.exist?(recipe_path) || raise(ERRORS[200] % {path: recipe_path})
    @recipe_path = recipe_path
    recipe_valid?
  end

  def check(**options)
    @options = options || {}
    proceed_check(**options)
  end

  # = main =
  # 
  # La méthode (silencieuse) qui produit le check
  # ("silencieuse" parce qu'elle ne produit que des raises)
  def proceed_check(**options)
    @options = options
    @reporter = Reporter.new(self)
    @reporter.start
    recipe[:tests].collect do |dtest|
      Test.new(self, dtest)
    end.each do |test|
      test.check(**options)
    end
    @reporter.end
    if no_output?
      return @reporter
    else
      @reporter.display
    end
  end

  # -- Predicate Methods --

  def base?
    not(base.nil?)
  end

  def no_output?
    options[:return_result] === true
  end

  def recipe_valid?
    not(recipe.nil?)            || raise(RecipeError, ERRORS[202])
    recipe.is_a?(Hash)          || raise(RecipeError, ERRORS[203] % {c: recipe.class.name})
    unless recipe.key?(:name) && name.is_a?(String) && not(name.empty?)
      raise(RecipeError, ERRORS[206])
    end
    recipe.key?(:tests)         || raise(RecipeError, ERRORS[204] % {ks: recipe.keys.pretty_inspect})
    recipe[:tests].is_a?(Array) || raise(RecipeError, ERRORS[205] % {c: recipe[:tests].class.name})
  end

  # --- Données ---

  def name
    @name ||= recipe[:name]
  end

  # [String] La base pour l'url
  def base
    @base ||= recipe[:base]
  end

  # [Hash] Les données de la recette, ou simplement "la recette"
  # 
  def recipe
    @recipe ||= YAML.safe_load(File.read(recipe_path), **YAML_OPTIONS)
  end
  alias :data :recipe


end #/class Checker
end #/module Lazy
