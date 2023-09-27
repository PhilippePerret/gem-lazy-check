module Lazy
class Checker
class CheckedTag

  class CheckCaseError < StandardError; end

  attr_reader :data
  
  # Instanciation
  # 
  # 
  def initialize(data)
    @data = data
    parse_tag
    check_data
  end

  
  # --- TESTS METHODS ---

  # =main=
  # 
  # @return true si le checked-tag se trouve dans le XML::Element
  # Nokogiri +noko+
  # 
  # @param noko [Nokogiri::XML::Element] L'élément qui doit contenir le checked-tag courant
  # 
  def is_in?(noko)
    if noko.document?
      # 
      # <= L'élément envoyé est un document Nokogiri
      #    Nokogiri::HTML4/5::Document
      # 
      founds = noko.css("//#{data[:tag]}")
      puts "Nombre de trouvés : #{founds.count}".bleu
    else
      #
      # <= L'élément envoyé est un node (un XML::Element)
      # => On doit chercher dans les enfans
      puts "Nombre d'enfants : #{noko.elements.count}".jaune
      noko.elements.each do |child|
        puts "child.node_name = #{child.node_name.inspect}".jaune
        # puts "child.methods = #{child.methods.join("\n")}".bleu
      end    
    end

    #
    # Pour mettre toutes les sous-erreurs rencontrées
    # 
    @sub_errors = []

    # On boucle sur les éléments trouvés.
    # 
    # Noter que +founds+ peut être vide, mais peu importe, on 
    # passera simplement la boucle. C'est pour ne pas répéter le
    # code en [1]
    founds = founds.select do |found|
      begin
        check_emptiness_of(found)
        check_containess_of(found)
        check_attributes_of(found)
        # S'il n'a pas raisé jusque-là, c'est qu'il est bon
        true
      rescue CheckCaseError => e
        @sub_errors << e.message
        false
      end
    end

    # [1] Si aucun élément n'a passé le test
    if founds.empty?
      if count === 0
        return true
      else
        _raise(4999, count || 'un nombre indéfini')
      end
    end

    founds_count = founds.count
    puts "Il en reste : #{founds_count}".bleu

    # 
    # Propriété :count
    # 
    if must_have_count? && ( founds_count != count )
      _raise(5000, count, founds_count, :count)
    end


    # 
    # Sinon, c'est un plein succès
    # 


  rescue CheckCaseError => e
    @error = e.message
    return false
  else
    return true
  end


  # --
  # -- Check précis d'un node (Nokogiri::XML::Element) trouvé
  # -- correspond à la recherche
  # --
  def check_emptiness_of(found)
    if must_be_empty? && not(found.empty?)
      _raise(5001, nil, found.content)
    elsif must_not_be_empty? && found.empty?
      _raise(5002)
    end
  end

  def check_containess_of(found)
    if must_have_content? && not(found.contains?(contains))
      _raise(5010, data[:contains].inspect, found.errors.pretty_join)
    end
  end

  # --
  # -- Vérifie que +found+ contienne bien les attributs 
  # -- attendu par le check
  # --
  def check_attributes_of(found)
    if must_have_attributes? 
      missing_attrs = found.attributes?(attributes)
      if not(missing_attrs.empty?)

      end
    end
  end

  # -- Predicate Methods --

  def must_be_empty?
    :TRUE == @mbempty ||= true_or_false(empty === true)
  end
  def must_not_be_empty?
    :TRUE == @mnbempty ||= true_or_false(empty === false)
  end
  def must_have_content?
    :TRUE == @mhcontent ||= true_or_false(not(contains.nil?))
  end
  def must_have_count?
    :TRUE == @mhcount ||= true_or_false(not(count.nil?))
  end
  def must_have_attributes?
    :TRUE == @mhattrs ||= true_or_false(not(attributes.nil?))
  end

  # -- Data Methods --

  def tag_name    ; @tag_name         end
  def id          ; @id               end
  def css         ; @css              end
  def tag         ; data[:tag]        end
  def count       ; data[:count]      end
  def empty       ; data[:empty]      end
  def contains    ; data[:contains]   end
  def attributes  ; data[:attrs]      end

  private


    def _raise(errno, expected = nil, actual = nil, property = nil)
      derror = {tag: tag, e: expected, a:actual}
      raise CheckCaseError.new(ERRORS[errno] % derror)
    end


    # Méthode qui décompose la donnée :tag pour en tirer le nom
    # de la balise (@tag_name), l'identifiant (@tag_id) et les
    # classes css (@tag_classes)
    def parse_tag
      tag = data[:tag].downcase
      found = tag.match(REG_TAG)
      @tag_name = found[:tag_name]
      @id   = found[:tag_id].to_s.strip
      @id   = nil if @id.to_s.empty?
      @css  = found[:tag_classes].to_s.split('.')
      @css  = nil if @css.empty?
    end
    REG_TAG = /^(?<tag_name>[a-z_\-]+)(\#(?<tag_id>[a-z0-9_\-]+))?(\.(?<tag_classes>[a-z0-9_\-\.]+))?$/.freeze

    def check_data
      id || css || raise(ArgumentError.new(ERRORS[1003] % {a: tag}))
      if count
        count.is_a?(Integer) || raise(ArgumentError.new(ERRORS[1004] % {a: count.inspect, c: count.class.name}))
      end 
    end


end #/class CheckedTag
end #/class Checker
end #/module Lazy
