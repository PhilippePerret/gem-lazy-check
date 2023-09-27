module Lazy
class Checker
class CheckedTag

  attr_reader :data
  
  # Instanciation
  # 
  # 
  def initialize(data)
    @data = data
    parse_tag
  end

  
  # --- TESTS METHODS ---

  # @return true si le checked-tag se trouve dans le XML::Element
  # Nokogiri +noko+
  # 
  # @param noko [Nokogiri::XML::Element] L'élément qui doit contenir le checked-tag courant
  # 
  def is_in?(noko)
    puts "Nombre d'enfants : #{noko.elements.count}".jaune
    noko.elements.each do |child|
      puts "child.node_name = #{child.node_name.inspect}".jaune
      # puts "child.methods = #{child.methods.join("\n")}".bleu
    end    
      exit 1
  end


  # -- Data Methods --

  def tag_name  ; @tag_name   end
  def id        ; @id         end
  def css       ; @css        end

  private


    # Méthode qui décompose la donnée :tag pour en tirer le nom
    # de la balise (@tag_name), l'identifiant (@tag_id) et les
    # classes css (@tag_classes)
    def parse_tag
      tag = data[:tag].downcase
      found = tag.match(REG_TAG)
      @tag_name = found[:tag_name]
      @id   = found[:tag_id]
      @css  = found[:tag_classes].to_s.split('.')
    end
    REG_TAG = /^(?<tag_name>[a-z_\-]+)(\#(?<tag_id>[a-z0-9_\-]+))?(\.(?<tag_classes>[a-z0-9_\-\.]+))?$/.freeze

end #/class CheckedTag
end #/class Checker
end #/module Lazy
