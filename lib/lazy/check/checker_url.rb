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
    @uri_string = uri
  end

  # @return Nokogiri Document
  def nokogiri
    # @nokogiri ||= Nokogiri::HTML(code_html)
    @nokogiri ||= Nokogiri::XML(code_html)
  end

  def code_html
    @code_html ||= read
  end
  
  def read
    if uri_string.start_with?('http')
      uri = URI(uri_string)
      Net::HTTP.get_response(uri).body
    elsif uri_string.start_with?('<') and uri_string.end_with?('>')
      uri_string
    else
      raise ArgumentError.new(ERRORS[201] % {a:uri_string.inspect})
    end
  end

  private


end #/class Url
end #/class Checker
end #/module Lazy
