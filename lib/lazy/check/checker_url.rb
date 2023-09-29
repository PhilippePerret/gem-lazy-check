require 'net/http'
require 'nokogiri'

module Lazy
class Checker
class Url

  attr_reader :uri_string
  
  # Instanciation d'un test
  # 
  # @param uri [String] URL ou code
  # 
  def initialize(uri)
    @uri_string = uri.strip
  end

  # @return Nokogiri Document
  def nokogiri
    @nokogiri ||= Nokogiri::XML(code_html)#.tap { |n| dbg("Classe : #{n.class}".bleu)}
  end

  # -- Predicate Methods --

  # @return true si la page a pu être chargée correctement
  def ok?
    not(code_html.nil?)
  end

  # @return true si la page est une redirection
  # @note la redirection se trouve dans @redirect_to
  def redirection?
    code_html.nil? && not(@redirect_to.nil?)
  end

  # @return la redirection
  # 
  # @note Il faut avoir appelé #code_html ou #read avant de
  # pouvoir l'utiliser.
  def redirect_to
    @redirect_to
  end

  # @return la response.value
  # @note Il faut que #code_html ou #read ait été appelé avant
  def rvalue
    @rvalue
  end

  def code_html
    @code_html ||= readit
  end
  
  def readit
    if uri_string.start_with?('http')
      uri = URI(uri_string)
      begin
        response = Net::HTTP.get_response(uri)
      rescue SocketError => e
        @rvalue = e.message.match(/([4][0-9][0-9])/).to_a[1].to_i
        return
      rescue Net::HTTPServerException => e
        @rvalue = e.message.match(/([4][0-9][0-9])/).to_a[1].to_i
        return
      rescue Net::HTTPClientException => e
        @rvalue = e.message.match(/([4][0-9][0-9])/).to_a[1].to_i
        return
      end
      begin
        @rvalue = response.value
      # rescue Net::HTTPServerException => e
      #   @rvalue = e.message.match(/([4][0-9][0-9])/).to_a[1].to_i
      #   puts "rvalue: #{@rvalue.inspect}".jaune
      #   exit
      #   return
      rescue Net::HTTPClientException => e
        @rvalue = e.message.match(/([4][0-9][0-9])/).to_a[1].to_i
        return
      end
      case response
      when Net::HTTPSuccess
        body = response.body # toute la page html
        @rvalue = response.code.to_i
        # dbg("response.value = #{response.methods.inspect}".bleu)
        # dbg("response.code = #{response.code.inspect}".bleu)
        if body.match?(REG_REDIRECTION)
          #
          # -- la page html définit une redirection par
          #    balise meta --
          # 
          @redirect_to = body.match(REG_REDIRECTION).to_a[1].strip
          return nil
        else
          # 
          # Un corps de page normal (note : <html>...</html>)
          # 
          return body
        end
      when Net::HTTPRedirect
        @redirect_to = response['location']
        return nil
      else
        return nil
      end
    elsif uri_string.start_with?('<') and uri_string.end_with?('>')
      uri_string
    else
      raise ArgumentError.new(ERRORS[201] % {a:uri_string.inspect})
    end
  end

  REG_REDIRECTION = /<meta.+http-equiv="refresh".+content="[0-9]+;(.+)">/.freeze


end #/class Url
end #/class Checker
end #/module Lazy
