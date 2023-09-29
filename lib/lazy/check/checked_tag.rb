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
    @error = nil
  end

  # @return les erreurs rencontrées
  def errors
    err = []
    # err << "Erreur avec #{data.inspect}" # Pour obtenir précisément les données
    err << @error.strip unless @error.nil?
    err << @errors.join("\n") unless @errors.empty?
    err << @sub_errors.join("\n") unless @sub_errors.empty?
    return err.join("\n")
  end

  def message
    MESSAGES[4999] % {tag: tag}
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

    # puts "is_in? avec noko : #{noko.inspect}".bleu
    #
    # Array dans lequel seront placés tous les candidats, jusqu'aux
    # derniers
    # 
    founds = []

    #
    # Pour mettre les erreurs
    # 

    @errors = []

    #
    # Traitement différent en fonction du fait qu'il s'agisse d'un
    # document Nokogiri ou d'un XML::Element Nokogiri
    # 
    if noko.document?
      # 
      # <= L'élément envoyé est un document Nokogiri
      #    Nokogiri::HTML4/5::Document
      # 
      if direct_child_only?
        noko.children.first.children.each do |child|
          founds << child if tagname_id_class_ok?(child)
        end
      else       
        founds = noko.css("//#{data[:tag]}")
      end
    elsif direct_child_only?
      #
      # Si on ne doit pas traverser toutes les générations d'éléments
      # 
      noko.children.each do |child|
        founds << child if tagname_id_class_ok?(child)
      end
    else
      #
      # Si on peut traverser toutes les générations d'éléments
      # 
      #
      # <= L'élément envoyé est un node (un XML::Element)
      # => On doit chercher dans les enfants
      # 
      noko.traverse_children do |child|
        # puts "child: #{child.inspect}".bleu
        founds << child if tagname_id_class_ok?(child)
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
        check_lengths_of(found)
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
    # puts "Il en reste : #{founds_count}".bleu

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

  def tagname_id_class_ok?(child)
    name_ok = child.node_name == tag_name
    id_ok   = id.nil? ? true : child.id == id
    css_ok  = css.nil? ? true : child_has_css?(child.classes, css)
    return name_ok && id_ok && css_ok
  end

  # --
  # -- Check précis d'un node (Nokogiri::XML::Element) trouvé
  # -- correspond à la recherche
  # --
  # @note
  #   Il existe deux sorte d'emptiness :
  #   1. l'absence de texte (mais le node peut contenir d'autres nodes)
  #   2. la vrai emptiness quand le node ne contient vraiment rien
  def check_emptiness_of(found)
    # puts "must_be_empty? #{must_be_empty?.inspect}".jaune
    # puts "found.empty? #{found.empty?.inspect}".bleu
    if must_be_empty? && not(found.empty?)
      _raise(5001, nil, found.content)
    elsif must_not_be_empty? && found.empty?
      _raise(5002)
    elsif must_have_no_text? && (found.has_text?)
      _raise(5003, nil, found.text)
    elsif must_have_text? && (found.has_no_text?)
      _raise(5004)
    end
  end

  def check_containess_of(found)
    if must_have_text? && not(found.match?(text))
      _raise(5011, text.inspect)
    end
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
      if missing_attrs.empty?
        return true # ne sert pas vraiment
      else
        # Il y a des attributs manquants
        _raise(5031, missing_attrs.inspect)
      end
    end
  end

  # --
  # -- Vérifie la longueur du contenu si :max_length ou 
  # -- :min_length ont été définis
  # --
  def check_lengths_of(found)
    if must_have_lengths?
      len = found.length.freeze
      if min_length && len < min_length
        _raise(5032, min_length, len)
      end
      if max_length && len > max_length
        _raise(5033, max_length, len)
      end
    end
  end

  # @return true si les +child_css+ contiennent toutes les +css+
  # 
  def child_has_css?(child_css, csss)
    csss.each do |css|
      return false if not(child_css.include?(css))
    end
  end


  # -- Predicate Methods --

  def direct_child_only?
    :TRUE == @directchild ||= true_or_false((data[:direct_child_only]||data[:direct_child]) === true)    
  end
  def must_have_text?
    :TRUE == @mhtxt ||= true_or_false(notext === false || not(text.nil?))
  end
  def must_have_no_text?
    :TRUE == @mhnotxt ||= true_or_false(notext === true)
  end
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
  def must_have_lengths?
    :TRUE == @mhlens ||= true_or_false(not(min_length.nil? && max_length.nil?))
  end

  # -- Data Methods --

  def name        ; data[:name]       end
  def tag_name    ; @tag_name         end
  def id          ; @id               end
  def css         ; @css              end
  def tag         ; data[:tag]        end
  def text        ; data[:text]       end
  def count       ; data[:count]      end
  def empty       ; data[:empty]      end
  def notext      ; data[:notext]     end
  def contains    ; data[:contains]   end
  def max_length  ; data[:max_length] end
  def min_length  ; data[:min_length] end
  def attributes  ; data[:attrs]      end

  private

    def _raise(errno, expected = nil, actual = nil, property = nil)
      derror = {tag: tag, e: expected, a:actual}
      raise CheckCaseError.new(ERRORS[errno].strip % derror)
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
      # id || css || raise(ArgumentError.new(ERRORS[1003] % {a: tag}))
      if count
        count.is_a?(Integer) || raise(ArgumentError.new(ERRORS[1004] % {a: count.inspect, c: count.class.name}))
      end 
    end


end #/class CheckedTag
end #/class Checker
end #/module Lazy
