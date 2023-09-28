# Lazy::Check

Ce gem permet de tester de façon paresseuse un site web.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lazy-check'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install lazy-check

## Usage

### Pour un test simple

~~~ruby
require 'lazy-check'

code = "<root><div class="contient">du texte</div></root>"
check = {tag: 'div.contient', text: "du texte"}
Lazy::Checker.check(code, check)
# => Écrit :
#       -------------------------------------
#       Succès 1 Failure 0 Temps ...
~~~

On peut aussi obtenir les résultats en retour de méthode (c'est un `Lazy::Checker::Reporter`)

~~~ruby
Lazy::Checker.check(code, check, **{return_result: true})
# => Reporter
~~~

Noter que dans ce cas-là, rien n'est écrit en console.

## Pour un test avec recette

Une « recette » est un fichier `YAML` qui définit l'url d'une page internet, ainsi que les checks à effectuer dessus. Cf. ci-dessous.

~~~ruby
require "lazy-check"

checker = Lazy::Checker.new("path/to/recipe.yaml")
checker.check
# => Produit le résultat
~~~

Si la recette se trouve là où le terminal se trouve, il suffit de faire :

~~~ruby
require "lazy-check"

Lazy::Checker.new.check
~~~

La recette (`recipe.yaml`) définit les vérifications qu'il faut effectuer.

~~~yaml
---
url: https://path/to/page/to/examine.html
checks:
  - name: "Existence du DIV#content avec du texte"
    tag: 'div#content'
    empty: false
  - name: "Existence du SPAN#range sans texte"
    tag: 'span#range'
    empty: true
~~~

### Properties

~~~yaml
tag:                  [String] Le sélector
count:             [Integer] Nombre attendu d'éléments
empty:            [Bool] Si doit être vide ou non vide
direct_child_only:   [Bool] Si doit être un enfant direct
text:                 [String] Le texte qui doit être contenu
contains:       [String|Array] Ce que doit contenir la page
~~~

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PhilippePerret/lazy-check.

