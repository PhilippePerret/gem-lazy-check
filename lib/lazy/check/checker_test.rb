module Lazy
class Checker
class Test

  attr_reader :data
  # Instanciation d'un test
  # 
  # @param data [Hash] Table de données du test
  # 
  def initialize(data)
    @data = data
    check_data
  end

  # On procède à ce test qui doit réussir
  # Ça consiste à boucler sur tous les :checks défini pour
  # ce test dans la recette.
  # Cf. checker_url.rb pour le détail
  def check
    data[:checks].each do |dcheck|
      check_case = CheckCase.new(urler, dcheck)
      result = check_case.check
      if result === true
        # Success
      elsif result === false
        # Failure
      else
        # Unknown result — Résultat inconnu

      end
    end
  end

  def urler
    @urler ||= Url.new(data[:url])
  end

  private


    def check_data
      data.is_a?(Hash)            || raise("Les données du test devraient être une table.")
      data.key?(:url)             || raise("Les données du test devraient définir :url.")
      data[:url].is_a?(String)    || raise(ERRORS[800] % {class: "#{data[:url].class}"})
      data.key?(:name)            || raise("Les données du test devraient avoir un :name")
      data.key?(:checks)          || raise("Les données du test devraient définir les checks à faire (:checks).")
      data[:checks].is_a?(Array)  || raise("Les checks à faire du test devraient être une liste.")
    end

end #/class Test
end #/class Checker
end #/module Lazy
