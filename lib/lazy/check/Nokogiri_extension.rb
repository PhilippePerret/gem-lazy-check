module Nokogiri
  class XML::Element

    # Liste [Array] des erreurs rencontrées au cours d'un check
    # Il faut penser initialiser (@errors = []) cette valeur au 
    # début d'un check
    attr_reader :errors

    # @return true si le node est vraiment vide
    def empty?
      not(children?) && content.empty?
    end

    def children?
      elements && elements.count > 0
    end

    # Test du contenu
    # 
    # @return true si le node courant contient tout ce qui est défini
    # dans +required+
    # 
    # @param required [String|Hash|Array] les choses qu'on doit 
    #                 trouver dans le noeud. Ça peut être un simple
    #                 texte définissant soit un texte soit une balise, 
    #                 une table définissant une balise ou une liste 
    #                 de ces différentes choses.
    def contains?(requireds)
      @errors = []
      @ok     = true
      requireds = [requireds] unless requireds.is_a?(Array)

      #
      # Recherche sur tous les éléments requis
      # 
      # On ne s'arrête pas, même si une erreur a été trouvée, pour
      # pouvoir les relever toutes.
      # 
      requireds.each do |required|
        # 
        # Qu'est-ce qu'on doit chercher ?
        # 
        case required
        when String
          if required.match?(/[^ ]/) && required.match?(/[#.]/)
            contains_as_tag?({tag: required})
          else
            contains_as_string?(required)
          end
        when Hash
          contains_as_tag?(required)
        else
          # Erreur d'implémentation, je dois m'arrêter
          raise CheckCaseError.new(ERRORS[2000] % {c: required.class.name})
        end
      end

      return @errors.empty? # true si OK
    end
    #/ contains?


    # @return true si le node contient le texte +searched+
    # (mais ce retour ne sert pas à grand-chose, en fait, et même
    #  à rien)
    # Surtout : ajoute une erreur à @errors si une erreur est
    # rencontrées.
    def contains_as_string?(searched)
      if text.include?(searched)
        return true
      else
        @errors << (ERRORS[5020] % {e: searched})
        return false
      end
    end

    # @return true si le node contient le node +dtag+ ou produit
    # une erreur dans @errors
    # 
    def contains_as_tag?(dtag)
      ctag = Lazy::Checker::CheckedTag.new(dtag)
      if ctag.is_in?(self)
        return true
      else
        @errors << (ERRORS[5021] % {e: dtag.inspect})
        return false
      end
    end

    # # @return [Array] Liste des attributs qui manque à l'élément
    # # par rapport à attrs
    # def attributes?(attrs)
    #   attrs.select do |attr_name, attr_value|
    #     if self.key?(attr_name) && self.attr(attr_name) == attr_value
    #       false
    #     else
    #       true
    #     end
    #   end
    # end

  end #/class XML::Element
end #/module Nokogiri
