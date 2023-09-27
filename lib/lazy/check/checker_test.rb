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
      # -- Pour simplifier l'écriture des erreurs --
      data_keys   = data.keys.pretty_join
      data_class  = data.class.name
      # -- Tests de validité --
      data.is_a?(Hash)            || raise(ERRORS[300] % {c: data_class})
      data.key?(:url)             || raise(ERRORS[300] % {ks: data_keys})
      err = check_url(data[:url])
      err.nil?                    || raise(ERRORS[302] % {e: err, u: data[:url]})
      data.key?(:name)            || raise(ERRORS[307] % {ks: data_keys})
      data.key?(:checks)          || raise(ERRORS[308] % {ks: data_keys})
      data[:checks].is_a?(Array)  || raise(ERRORS[309] % {c: data_class})
    end

    # S'assure que +url+ est une url valide. @return nil si c'est le
    # cas où l'erreur dans le cas contraire.
    # 
    # @note 
    # 
    #   Ce qu'on appelle une +url+ ici peut être un URI (https://...)
    #   ou le code résultant du chargement de cette URI, qui sera 
    #   reconnaissable parce qu'il commence par "<" et finit par ">"
    #   (oui, c'est de la reconnaissance paresseuse…)
    # 
    def check_url(url)
      url                     || raise(ERRORS[303])
      url.is_a?(String)       || raise(ERRORS[304] % {c: url.class.name})
      if url.match?(/^<.+>$/.freeze)
        # Du code HTML/XML
      else
        url.start_with?('http') || raise(ERRORS[305])
        not(url.match?(/ /))    || raise(ERRORS[306])
      end
    rescue Exception => e
      return e.message
    else
      return nil
    end

end #/class Test
end #/class Checker
end #/module Lazy
