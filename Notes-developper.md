# Lazy::Checker, notes développeur

## Fonctionnement général du check

L'utilisateur crée une instance `Lazy::Checker` (`checker.rb`) avec une adresse de recette (ou la recette présente dans le dossier où a été ouvert le Terminal)

L'utilisateur appelle alors la méthode `#check` de cette instance, avec ou sans options (pour le moment, les options permettent seulement de déterminer si on doit afficher le résultat ou le retourner.

La méthode `#check` vérifie si la recette est valide, et appelle le cas échéant la méthode `#proceed_check` avec les options.

La méthode `Lazy::Checker#proceed_check` crée un rapporteur (`Lazy::Checker::Reporter`), le démarre et boucle sur chaque test de la propriété `:tests de la recette` (un `Array`).

Pour chaque test, la méthode crée une instance `Lazy::Checker::Test` en lui donnant en argument l'instance checker (donc elle-même) et les données du test.

> Parmi ces données de test se trouve `:url` qui détermine l'adresse URI qu'il va falloir tester, ainsi que `:checks` qui détermine la liste des checks à effectuer.

Une fois tous les tests instanciés, on appelle leur méthode `#check`. Cette méthode boucle sur la propriété `:checks` des données du check, instancie un `Lazy::Checker::CheckCase` et appelle sa méthode `#check`.

La méthode `Lazy::Checker::CheckCase#check` crée une instance `Lazy::Checker::CheckedTag` à partir des données du cas (celles qui contiennent `:tag`, `:text`, `:contains`, etc.) et vérifie que ce « tag » appartienne bien au conteneur défini par l'URL à l'aide de la méthode `#is_in?` qui est, pourrait-on dire, le cœur de ce gem.

La méthode `#is_in?` retourne true ou false et crée respectivement un succès ou un échec dans le rapporteur.


~~~yaml
# --- La recette --- #=> instance Lazy::Checker
name: Test d'une page internet
base:  https:://mon_site.com # toutes les adresses sont vues par là
# Les tests
tests: 
  - name: Nom du premier test #=> instance Lazy::Checker::Test
    url: relative/to/page
    checks:
			# :url + 1 :check =>  instance Lazy::Checker::CheckCase
			- tag: div#mondiv.content   #=> instance Lazy::Checker::CheckedTag
        count: 1
        text: "Bonjour tout le monde !"
      - tag: div#autre_div            #=>  instance Lazy::Checker::CheckedTag


