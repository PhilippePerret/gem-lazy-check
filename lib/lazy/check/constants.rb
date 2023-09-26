KNOWN_LANGS = ['fr','en']

lang = ENV['LANG'][0..1] || 'en'
# lang = 'en' # pour tester
lang = 'en' unless KNOWN_LANGS.include?(lang)
LANG = lang


YAML_OPTIONS = {symbolize_names:true, aliases:true, permitted_classes:[Date,Integer,Float]}

ERRORS = YAML.safe_load(File.read(File.join(__dir__,'locales',LANG,'errors.yaml')), **YAML_OPTIONS)
