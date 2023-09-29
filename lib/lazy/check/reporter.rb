#
# Class Lazy::Checker::Reporter
# 
# Pour établie le rapport de fin.
# 
module Lazy
class Checker
  class Reporter

    attr_reader :checker

    def initialize(checker)
      @checker = checker
    end

    #
    # Affichage du rapport
    # 
    def display
      puts "\n\n"
      puts "#{checker.name}".jaune
      puts "-"* checker.name.length
      nombre_erreurs = @failures.count
      if true #verbose? # TODO À RÉGLER
        @successs.each do |checked|
          puts checked.message.vert
        end
      end
      if nombre_erreurs > 0
        @failures.each do |checkedthing|
          puts "#{checkedthing.error}".rouge
        end
      end
      color = nombre_erreurs > 0 ? :red : :vert
      msg = "Success #{@successs.count} Failures #{@failures.count} Temps #{formated_duree}"
      puts "-" * msg.length
      puts msg.send(color)
    end

    def add_success(check_case)
      @successs << check_case
    end
    def add_failure(check_case)
      @failures << check_case
    end

    def start
      @start_time = Time.now
      @successs = []
      @failures = []
    end

    def end
      @end_time = Time.now
    end

    def formated_duree
      @formated_duree ||= begin
        if duree < 0.10
          "#{(duree.to_f * 1000).round(4)} ms"
        else
          "#{duree.round(4)} s"
        end
      end
    end
    def duree
      @duree ||= @end_time - @start_time
    end

  end #/class Reporter
end #/class Checker
end #/module Lazy
