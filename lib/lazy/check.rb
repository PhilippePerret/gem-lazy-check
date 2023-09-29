require 'clir'
require 'yaml'
require 'nokogiri'
require "lazy/check/version"
require 'lazy/check/constants'
require "lazy/check/checker"
require "lazy/check/checker_test"
require "lazy/check/checker_url"
require "lazy/check/checked_tag"
require "lazy/check/checked_url"
require 'lazy/check/Nokogiri_extension'
require "lazy/check/checker_case"
require "lazy/check/checker_code"
require "lazy/check/reporter"

def dbg(msg)
  STDOUT.write "\n#{msg}"
end
