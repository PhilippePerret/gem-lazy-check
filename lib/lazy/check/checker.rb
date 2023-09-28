module Lazy
class Checker

  attr_reader :recipe_path

  def initialize(recipe_path = nil)
    recipe_path ||= File.expand_path('.', 'recipe.yaml')
    File.exist?(recipe_path) || raise(ERRORS[200] % {path: recipe_path})
    @recipe_path = recipe_path
  end

  def check(**options)
    recipe_valid? && proceed_check(**options)
  end

  # = main =
  # 
  # La méthode (silencieuse) qui produit le check
  # ("silencieuse" parce qu'elle ne produit que des raises)
  def proceed_check(**options)
    @report = Reporter.new(self)
    @report.start
    recipe[:tests].collect do |dtest|
      Test.new(dtest)
    end.each do |test|
      test.check
    end
    @report.end
    if options[:return_result]
      return @report
    else
      @report.display
    end
  end

  def recipe_valid?
    not(recipe.nil?)            || raise(ERRORS[202])
    recipe.is_a?(Hash)          || raise(ERRORS[203] % {c: recipe.class.name})
    recipe.key?(:tests)         || raise(ERRORS[204] % {ks: recipe.keys.pretty_inspect})
    recipe[:tests].is_a?(Array) || raise(ERRORS[205] % {c: recipe[:tests].class.name})
  end

  # [Hash] Les données de la recette, ou simplement "la recette"
  # 
  def recipe
    @recipe ||= YAML.safe_load(File.read(recipe_path), **YAML_OPTIONS)
  end
  alias :data :recipe

end #/class Checker
end #/module Lazy
