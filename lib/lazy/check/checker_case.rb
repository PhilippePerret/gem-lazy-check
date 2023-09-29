#
# Un cas de test
# --------------
# 
# C'est un cas absolument unique, par exemple on cherche :
# 
#   Un div d'identifiant #mondiv qui n'est pas vide
# ou
#   Un div d'identifiant #mondiv qui contient le texte "Coucou"
# ou
#   Un div d'identifiant #mondiv qui contient une balise <li>
# *MAIS*
#   pas les trois en même temps, même s'ils sont définis dans le
#   même 'check'
# 
module Lazy
class Checker
class CheckCase

  attr_reader :urler
  attr_reader :data
  attr_reader :reporter

  # Instanciation d'un cas de test
  # 
  # @param urler [Hash] Checker::Url parsé à utiliser
  # 
  # @param data [Hash]  Les données du check, tels que définis dans
  #                     la recette du test. Sera transformé en une
  #                     CheckedTag
  # 
  #   :tag          [String] [Requis] La balise, l'identifiant et les classes. Par exemple "div#mondiv.maclasse.autreclasse"
  #   :count        [Integer] Nombre d'éléments à trouver
  #   :empty        [Boolean] true si doit être vide, false si ne doit pas être vide
  #   :direct_child [Boolean] true si doit être un enfant direct (mais sert plutôt pour les sous-éléments à checker)
  #   :attrs        [Hash]    Attributs à trouver
  #   :contains     [Array|String] Ce que doit contenir le noeud
  # 
  def initialize(urler, data, reporter = nil)
    urler.is_a?(Lazy::Checker::Url) || raise(ArgumentError.new(ERRORS[1000] % {a:urler,c:urler.class.name}))
    @data   = data
    check_data
    @urler  = urler
    @reporter = reporter
  end

  # La nouvelle façon de checker
  def check
    ctag = CheckedTag.new(data)
    if ctag.is_in?(noko)
      # reporter.add_success(self) if reporter
      reporter.add_success(ctag) if reporter
      return true
    else
      # reporter.add_failure(self) if reporter
      reporter.add_failure(ctag) if reporter
      return false
    end
  end

  # -- Data / Predicate de check --

  # -- Données / Predicate utiles pour checker --
  # (noter que toutes ces valeurs ne sont estimées que si elles
  #  sont utilisées)

  # @return true si la balise contient quelque chose
  def has_content?
    not(content.empty?)
  end

  # @return true si la balise ne contient rien
  def not_has_content?
    content.empty?
  end

  # @return le contenu de la balise, sous forme de string
  # 
  def content
    tag.content
  end


  # -- Données du Case --

  def tag
    data[:tag]
  end

  def noko
    @noko ||= urler.nokogiri
  end

  attr_reader :debug

  private 

    #
    # Vérification de la donnée de check transmise à l'instanciation
    # 
    # @note
    #   C'est elle qui va servir à l'instanciation du CheckedTag
    # 
    def check_data
      data.is_a?(Hash)  || raise(ArgumentError.new(ERRORS[1001] % {a: data, c:data.class.name}))
      data.key?(:tag)   || raise(ArgumentError.new(ERRORS[1002] % {ks: data.keys.collect{|k|":#{k}"}.join(', ')}))
    end

end #/class CheckCase
end #/class Checker
end #/module Lazy
