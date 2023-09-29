#
# Class Lazy::Checker::CheckedUrl
# 
# Quand c'est la redirection ou la réponse qu'il faut checker. Donc
# quand il n'y a pas de :checks dans la définition du test.
# 
module Lazy
class Checker
class CheckedUrl

  attr_reader :data

  # [String] L'erreur éventuelle à écrire
  attr_reader :error
  
  # Instanciation
  # 
  # 
  def initialize(data)
    @data = data
  end

  # @return les erreurs rencontrées
  def errors
    @errors.join("\n") + "Sous-erreurs : #{@sub_errors.join("\n")}"
  end
  
  # --- TESTS METHODS ---

  def check(**options)
    urler.readit
    if test_redirection?
      if urler.redirection? && urler.redirect_to == data[:redirect_to]
        reporter.add_success(self)
      elsif urler.redirect_to.nil?
        @error = ERRORS[5500] % {e:data[:redirect_to]}
        reporter.add_failure(self)
      else
        @error = ERRORS[5501] % {a:urler.redirect_to, e:data[:redirect_to]}
        reporter.add_failure(self)
      end
    elsif test_response?
      # STDOUT.write("\nurler.rvalue = #{urler.rvalue.inspect}".jaune)
      if urler.rvalue == data[:response]
        reporter.add_success(self)
      else
        case urler.rvalue
        when 404
          @error = ERRORS[5503] % {e: urler.url}
        else
          @error = ERRORS[5502] % {a:urler.rvalue, e:data[:response]}
        end
        reporter.add_failure(self)
      end
    end
  end


  # -- Predicate Methods --

  def test_response?
    data.key?(:response) && not(data[:response].nil?)
  end

  def test_redirection?
    data.key?(:redirect_to) && not(data[:redirect_to].nil?)
  end

  # -- Data Methods --

  def urler     ; data[:urler]      end
  def name      ; data[:name]       end
  alias :message :name
  def reporter  ; data[:reporter]   end

  private


end #/class CheckedUrl
end #/class Checker
end #/module Lazy
