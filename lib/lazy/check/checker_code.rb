#
# Lazy::Checker::Code
# -------------------
# Classe pour utiliser Lazy::Check directement avec du code, sans
# passer par une URL ou une recette
# 
# @usage
# 
#   Lazy::Checker.check(<code html>, {<rechercher>})
# 
module Lazy
class Checker
  class << self
    
    # = main =
    # 
    # Pour une utilisation du gem avec :
    # 
    #   Lazy::Checker.check(<code XML>, {<données check>})
    # 
    # … qui produit un rapport.
    # 
    # Les données check doivent être conformes, c'est-à-dire contenir
    # au moins la propriété :tag qui définit une balise à trouver 
    # dans le code XML.
    # 
    # @param options [Hash] Cf. Lazy::Checker::Code#check_against
    # 
    def check(xml_code, data_check, **options)
      @xml_code   = check_xml_code(xml_code)
      @data_check = check_data_check(data_check)
      checker = Lazy::Checker::Code.new(@xml_code)
      checker.check_against(@data_check, **options)
    end

    private

      # Méthode qui vérifie la conformité de la donnée
      def check_xml_code(xml)
        xml                   || raise(ArgumentError, ERRORS[6003])
        xml.is_a?(String)     || raise(ArgumentError, ERRORS[6001] % {c: xml.class.name, a: xml.inspect})
        xml = is_rooted?(xml) || raise(ArgumentError, ERRORS[6002] % {a: xml.inspect})
        return xml
      rescue ArgumentError => e
        raise ArgumentError.new(ERRORS[6000] % {se: e.message})
      end

      def is_rooted?(xml_ini)
        xml = xml_ini.dup
        xml = xml.gsub(/\r?\n/,'')
        xml = xml.gsub(/^<\?xml version.+\?>/,'')
        xml = xml.strip
        if xml.match?(REG_ROOT)
          return xml
        else
          return nil
        end
      end

      REG_ROOT = /^<([a-zA-Z0-9:\-_]+)( .+?)?>.*<\/\1>$/.freeze

      # Méthode qui s'assure que les données de check (choses à
      # vérifier) est valide
      def check_data_check(dch)
        dch                   || raise(ArgumentError, ERRORS[6003])
        dch.is_a?(Hash)       || raise(ArgumentError, ERRORS[6011] % {c: dch.class.name, a: dch.inspect})
        dch.key?(:tag)        || raise(ArgumentError, ERRORS[1002] % {ks: dch.keys.pretty_join})
        return dch
      rescue ArgumentError => e
        raise ArgumentError.new(ERRORS[6010] % {se: e.message})
      end
  end #/<< self

  class Code

    attr_reader :urler

    # Le rapport courant (pour pouvoir être modifié en cours
    # de test)
    attr_reader :report

    attr_reader :options

    def initialize(xml_code)
      @xml_code = xml_code
      @urler = Checker::Url.new(xml_code)
    end

    # Méthode qui procède au check
    # 
    # @param options [Hash] 
    #   :return_result   Si true, on retourne les données au lieu de les afficher
    # 
    def check_against(data_check, **options)
      @options = options
      @report = Reporter.new(self)
      @report.start
      check_case = Checker::CheckCase.new(urler, data_check, @report)
      check_case.check
      @report.end
      if options[:return_result]
        return report
      else
        report.display
      end
    end

    def name
      MESSAGES[:CodeToTest]
    end

    def no_output?
      options[:return_result] === true
    end

  end #/class Code
end #/class Checker
end #/module Lazy
