module Lazy
class Checker
class Test

  # Instance Lazy::Checker principale qui lance les tests
  # 
  attr_reader :checker

  # Données du test
  # 
  # Doit contenir :
  #   - :url    [String] Adresse à visiter
  #   - :checks [Array] Liste des checks à faire
  # 
  attr_reader :data

  # Instanciation d'un test
  # 
  # @param data [Hash] Table de données du test
  # 
  def initialize(checker, data)
    @checker = checker
    @data = data
    check_data
  end

  # On procède à ce test qui doit réussir
  # Ça consiste à :
  #   - si :checks est défini : boucler sur tous les :checks pour
  #     ce test dans la recette.
  #   - si :redirect_to est défini : vérifier qu'on obtient bien une
  #     redirection.
  #   - si :response est défini : vérifier que c'est bien la réponse
  # 
  # Cf. checker_url.rb pour le détail
  # 
  def check(**options)
    if data.key?(:checks)
      check_with_checks(**options)
    else
      check_autre(**options)
    end
  end

  def check_with_checks(**options)
    data[:checks].each do |dcheck|
      check_case = CheckCase.new(urler, dcheck, checker.reporter)
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

  # Pour checker la redirection ou l'http response
  def check_autre(**options)
    # STDOUT.write "\n-> check_autre (data: #{data.inspect})".jaune
    churl = CheckedUrl.new(data.merge(urler: urler, reporter: reporter))
    churl.check(**options)
  end

  def urler
    @urler ||= begin
      full_url = checker.base ? File.join(checker.base, url) : url
      Url.new(full_url)
    end
  end

  def url
    @url ||= data[:url]
  end

  # raccourci
  def reporter
    checker.reporter
  end

  private


    def check_data
      # -- Pour simplifier l'écriture des erreurs --
      data_keys   = data.keys.pretty_join
      data_class  = data.class.name
      # -- Tests de validité --
      data.is_a?(Hash)                    || raise(ERRORS[300] % {c: data_class})
      data.key?(:url)                     || raise(ERRORS[300] % {ks: data_keys})
      err = check_url(data[:url])
      err.nil?                            || raise(ERRORS[302] % {e: err, u: data[:url]})
      data.key?(:name)                    || raise(ERRORS[307] % {ks: data_keys})
      if data.key?(:checks)
        data[:checks].is_a?(Array)        || raise(ERRORS[309] % {c: data_class})
      elsif data.key?(:redirect_to)
        data[:redirect_to].is_a?(String)  || raise(ERRORS[310] % {a: data[:redirect_to].inspect, c: data[:redirect_to].class.name})
        data[:redirect_to].start_with?('http')  || raise(ERRORS[311] % {a: data[:redirect_to].inspect})
      elsif data.key?(:response)
        data[:response].is_a?(Integer)    || raise(ERRORS[312] % {a:data[:response].inspect, c: data[:response].class.name})
      else
        raise(ERRORS[308] % {ks: data_keys})
      end
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
        if checker.base?
          # Pas à tester le début
        else
          url.start_with?('http') || raise(ERRORS[305])
        end
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
