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

  # Instanciation d'un cas de test
  # 
  # @param urler [Hash] Checker::Url parsé à utiliser
  # 
  # @param data [Hash] Les données du check, tels que définis dans
  #                         la recette du test.
  # 
  #   :tag  [Requis] La balise, l'identifiant et les classes. Par exemple "div#mondiv.maclasse.autreclasse"
  # 
  def initialize(urler, data)
    urler.is_a?(Lazy::Checker::Url) || raise(ArgumentError.new(ERRORS[1000] % {a:urler,c:urler.class.name}))
    data.is_a?(Hash) || raise(ArgumentError.new(ERRORS[1001] % {a: data, c:data.class.name}))
    @data   = data
    @urler  = urler
    check_data
  end

  def check
    # decompose_tag # analyse de data[:tag] fourni
    puts "noko = #{noko.inspect}".bleu
    puts "tag = #{tag.inspect}".bleu
    ary = noko.css("//#{tag}")
    ary_count = ary.count # pourra être rectifié
    puts "ary = #{ary.inspect}".bleu
    puts "ary_count = #{ary_count.inspect}".bleu
    if ary.empty?
      return false
    else
      # TODO On doit poursuivre les tests
      # 
      if count? && ary_count != count
        @error = "Bad count"
        return false
      end
      return true
    end
  end

  # -- Data --

  def empty?
    data[:empty] === true
  end
  def not_empty?
    data[:empty] === false
  end

  # @return true si on doit faire un check sur le nombre de
  # résultats
  def count?
    not(count.nil?)
  end


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

    # Méthode qui décompose la donnée :tag pour en tirer le nom
    # de la balise (@tag_name), l'identifiant (@tag_id) et les
    # classes css (@tag_classes)
    def decompose_tag
      tag = data[:tag].downcase
      found = tag.match(REG_TAG)
      @tag_name = found[:tag_name]
      @tag_id   = found[:tag_id]
      @tag_css  = found[:tag_classes].split('.')
    end
    REG_TAG = /^(?<tag_name>[a-z_\-]+)(\#(?<tag_id>[a-z0-9_\-]+))?(\.(?<tag_classes>[a-z0-9_\-\.]+))?$/.freeze

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
