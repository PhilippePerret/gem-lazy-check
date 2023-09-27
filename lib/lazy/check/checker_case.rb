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

  class CheckCaseError < StandardError; end

  attr_reader :urler
  attr_reader :data

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
  # 
  def initialize(urler, data)
    urler.is_a?(Lazy::Checker::Url) || raise(ArgumentError.new(ERRORS[1000] % {a:urler,c:urler.class.name}))
    data.is_a?(Hash) || raise(ArgumentError.new(ERRORS[1001] % {a: data, c:data.class.name}))
    @data   = data
    @urler  = urler
    check_data
  end

  # La nouvelle façon de checker
  def check
    ctag = CheckedTag.new(data)
    if ctag.is_in?(noko)
      puts "👍".vert
    else
      puts "👎".rouge
  end

  def OLD_check
    @sub_errors = []
    # puts "noko = #{noko.inspect}".bleu
    # puts "tag = #{tag.inspect}".bleu
    founds = noko.css("//#{tag}")
    founds_count = founds.count # pourra être rectifié
    # puts "founds = #{founds.inspect}".bleu
    puts "founds count = #{founds_count.inspect}".bleu
    if founds.empty?
      #
      # Aucun élément ne remplit les conditions du tag (nom de
      # balise, identifiant et/ou classes CSS)
      # 
      if count === 0
        return true
      else
        _raise(4999, count || 'un nombre indéfini')
      end
    else
      #
      # Des éléments remplissent les conditions
      # On va les filtrer et voir ce qui reste de valide.
      # 

      puts "\n\n\n"
      puts "Recherche dans #{tag.inspect}".bleu

      founds = founds.select do |found|
        # puts "found.methods: #{found.methods}".bleu
        # exit
        puts "\n\n"
        puts "found = #{found.to_s}".jaune
        puts "found = #{found.inspect}".jaune
        puts "found.children? #{found.children?.inspect}".jaune
        # exit 2
        puts "found.blank? #{found.blank?.inspect}".jaune
        puts "found.text? #{found.text?.inspect}".jaune
        puts "found.content : #{found.content.inspect}".jaune
        puts "found.content.empty? : #{found.content.empty?.inspect}".jaune
        puts "found.text : #{found.text.inspect}".jaune
        puts "found.text.empty? : #{found.text.empty?.inspect}".jaune
        # next
        # exit 1
        begin 

          #
          # -- Propriété :empty --
          # 
          if be_empty? && not(found.empty?)
            # on attend que le conteneur soit vide, mais il a du contenu
            _raise(5001, nil, found.content)
          elsif not_be_empty? && found.empty?
            # on attend un conteneur pas vide, mais il est vide
            _raise(5002)
          end

          #
          # -- Propriété :contains --
          # 
          if contains? && not(found.contains?(data[:contains]))
            _raise(5010, data[:contains].inspect, found.errors.pretty_join)
          end

          true
        rescue CheckCaseError => e
          @sub_errors << e.message
          false
        end
      end #/fin de boucle sur les founds

      # -- Nombre d'éléments restant --
      founds_count = founds.count

      puts "Il en reste : #{founds_count}".bleu

      # Maintenant que tous les éléments ont été filtrés, on peut
      # voir si le nombre qui reste correspond aux attentes :
      # - soit il y en a un certain nombre, sans contrainte sur le
      #   count.
      # - soit il y a une contrainte :count sur le nombre et elle
      #   est respectée ou trahie.

      if founds_count == 0
        _raise(4999, count || 'un nombre indéfini')
        # ATTENTION : C'EST PEUT-ÊTRE CE QUE L'ON CHERCHE, À NE
        # PAS TROUVER CET ÉLÉMENT
      end

      # 
      # Propriété :count
      # 
      if count? && founds_count != count
        _raise(5000, count, founds_count, :count)
      end

      #
      # Si on arrive ici c'est que c'est un plein succès
      # 
      return true
    end
  rescue CheckCaseError => e
    @error = e.message
    return false
  end

  def _raise(errno, expected = nil, actual = nil, property = nil)
    derror = {tag: tag, e: expected, a:actual}
    raise CheckCaseError.new(ERRORS[errno] % derror)
  end

  # -- Data / Predicate de check --

  def be_empty?
    data[:empty] === true
  end
  def not_be_empty?
    data[:empty] === false
  end

  # @return true si on doit faire un check sur le nombre de
  # résultats
  def count?
    not(count.nil?)
  end

  # @return true si on doit faire le check sur le contenu
  # 
  def contains?
    data.key?(:contains) && not(data[:contains].nil?)
  end

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

  def tag       ; data[:tag]      end
  def count     ; data[:count]    end
  def tag_name  ; @tag_name       end
  def tag_id    ; @tag_id         end
  def tag_css   ; @tag_css        end

  def noko
    @noko ||= urler.nokogiri
  end

  attr_reader :debug

  private 


    def check_data
      data.key?(:tag) || raise(ArgumentError.new(ERRORS[1002] % {ks: data.keys.collect{|k|":#{k}"}.join(', ')}))
      # data[:tag].match?(/[#.]/) || raise(ArgumentError.new(ERRORS[1003] % {a: data[:tag]}))
      # 
      # On pourra affiner encore les choses plus tard, en définissant
      # que s'il y a telle ou telle donnée, il faut que la valeur
      # soit comme ci ou comme ça.
      # 
    end
end #/class CheckCase
end #/class Checker
end #/module Lazy
