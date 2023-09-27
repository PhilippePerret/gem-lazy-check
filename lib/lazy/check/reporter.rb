#
# Class Lazy::Checker::Reporter
# 
# Pour établie le rapport de fin.
# 
module Lazy
class Checker
  class Reporter

    def initialize(checker)
      @checker = checker
    end

    #
    # Affichage du rapport
    # 
    def display
      puts "Je dois apprendre à afficher le rapport.".jaune
    end


    def start
      @start_time = Time.now
    end

    def end
      @end_time = Time.now
    end

    def duree
      @duree ||= @end_time - @start_time
    end

  end #/class Reporter
end #/class Checker
end #/module Lazy
