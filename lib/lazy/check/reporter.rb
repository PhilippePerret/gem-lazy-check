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
      clear unless debug?
      puts "\n\n"
      puts "#{checker.name}".jaune
      puts "-"* checker.name.length
      nombre_erreurs = @failures.count
      if true #verbose? # TODO À RÉGLER
        display_list_resultats(success = true)
      end
      if nombre_erreurs > 0
        display_list_resultats(success = false)
      end
      color = nombre_erreurs > 0 ? :red : :vert
      msg = "#{MESSAGES[:Success]} #{@successs.count} #{MESSAGES[:Failures]} #{@failures.count} #{MESSAGES[:Duration]} #{formated_duree}"
      puts "-" * msg.length
      puts msg.send(color)
    end

    def add_success(check_case)
      @successs << check_case
    end
    def add_failure(check_case)
      @failures << check_case
    end

    # Pour afficher la liste de succès ou de failures
    def display_list_resultats(success)
      methode = success ? :message   : :errors
      color   = success ? :vert      : :red
      liste   = success ? @successs  : @failures
      prefix  = success ? '👍'  : '👎'

      max_index = liste.count + 1
      max_len_index = "[#{prefix} #{max_index}] ".length
      indent = ' ' * max_len_index
      liste.each_with_index do |checkedthing, idx|
        index_str = "[#{prefix} #{idx + 1}]".ljust(max_len_index)
        puts "#{index_str}#{checkedthing.send(methode).split("\n").join("\n#{indent}")}".send(color)
      end
    end

    def start
      clear unless debug?
      puts "\n\n"
      puts "#{checker.name}".jaune
      puts MESSAGES[:PleaseWait].bleu
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
