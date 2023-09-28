$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "lazy/check"

require "minitest/autorun"

require 'minitest/reporters'
reporter_options = {
  color: true,          # pour utiliser les couleurs
  slow_threshold: true, # pour signaler les tests trop longs
}
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]


TEST_ERRORS = YAML.safe_load(File.read(File.join(__dir__,'locales',Lazy::LANG,'errors.yaml')), **Lazy::YAML_OPTIONS)

TEST_FOLDER = File.join(Lazy::APP_FOLDER, 'test')
