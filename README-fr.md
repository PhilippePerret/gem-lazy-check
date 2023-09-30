# Lazy::Check

Ce gem permet de tester de façon paresseuse un site web.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lazy-check'
require 'lazy/check'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install lazy-check

## Usage

### Pour un test simple (sans recette)

Si on a juste du code XML-like à tester, on peut utiliser la méthode `Lazy::Checker.check`.

~~~ruby
gem 'lazy-check'
require 'lazy/check'

code = "<root><div class="contient">du texte</div></root>"
check = {tag: 'div.contient', text: "du texte"}
Lazy::Checker.check(code, check)
# => Écrit :
#       -------------------------------------
#       Succès 1 Failure 0 Temps ...
~~~

On peut aussi obtenir les résultats en retour de méthode (c'est un `Lazy::Checker::Reporter`).

~~~ruby
Lazy::Checker.check(code, check, **{return_result: true})
# => Reporter
~~~

> Noter que dans ce cas-là, rien n'est écrit en console.

## Pour un test avec recette

Une « recette » est un fichier `YAML` qui définit l'url d'une page internet, ainsi que les checks à effectuer dessus. Cf. ci-dessous.

~~~ruby
require "lazy/check"

checker = Lazy::Checker.new("path/to/recipe.yaml")
checker.check
# => Produit le résultat
~~~

Si la recette se trouve là où le terminal se trouve, il suffit de faire :

~~~ruby
require "lazy/check"

Lazy::Checker.new.check
~~~

La recette (`recipe.yaml`) définit les vérifications qu'il faut effectuer.

~~~yaml
---
name: "Nom général de la recette"
base: https://www.mon.domaine.net
tests:
  - name: "Le premier test"
    url: "" # donc la base
    checks:
      - name: "Existence du DIV#content avec du texte"
        tag: 'div#content'
        empty: false
      - name: "Existence du SPAN#range sans texte"
        tag: 'span#range'
        empty: true
  
      - name: "Une redirection"
        url: "redirection.html"
        redirect_to: "https://nouvelle.url.net"

      - name: "Une page erronée"
        url: "page_inexistante.html"
        response: 404
~~~

### Check Properties

Les "checks" ci-dessus peuvent définir les propriétés suivantes :

~~~yaml
tag:                  [String] Le sélector
count:             [Integer] Nombre attendu d'éléments
empty:            [Bool] Si true, doit être vide, si false, non vide
direct_child:   [Bool] Si true, doit être un enfant direct
text:                 [String] Le texte qui doit être contenu
contains:       [String|Array] Ce que doit contenir la page
min_length: 		[Integer] La longueur minimum du contenu (text seulement)
max_length: 		[Integer] La longueur maximum du contenu (text seulement)
~~~

## Exemples

Simplement vérifier qu’une page réponde correctement :

~~~yaml
# recipe.yaml
---
name: "La page existe"
base: 'https://monsite.net'
tests: 
	- name: "La page index.html existe et répond correctement"
		url:  'index.html'
		response: 200
~~~

Vérifier qu’une page contient les éléments de base :

~~~yaml
# recipe.yaml
---
name: "Check simple de l'existence des éléments de base"
base: 'https://monsite.net'
tests: 
	- name: "La page index.html contient les éléments de base"
		url:  'index.html'
		checks:
			- tag: 'header'
			- tag: 'section#body'
			- tag: 'footer'
~~~

## Tester le gem

Lancer les tests avec :

~~~
rake test
~~~

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PhilippePerret/lazy-check.

