---------
#OVERVIEW
---------
Ce projet implémente un compilateur pour le langage Kawa, avec des fonctionnalités supportant les opérations arithmétiques, la gestion des variables, les instructions, les classes, les attributs, les méthodes, et l’héritage. 
De plus, des extensions ont été ajoutées pour enrichir le langage : déclaration en série, opérateur instanceof, modificateurs de visibilité (public, protected, private), et attributs final.

L’implémentation s’est déroulée en quatre grandes étapes :

kawalexer : Analyse lexicale.
kawaparser : Analyse syntaxique (grammaticale).
typechecker : Vérification des types et de la sémantique.
interpreter : Exécution du programme dans un environnement simulé.

-----------------------------
#Fonctionnalités implémentées
-----------------------------

## Fonctionnalités de base

-Opérations arithmétiques :
Support des opérations : addition, soustraction, multiplication, division et modulo.
Fonctionne dans tous les composants (kawalexer, kawaparser, typechecker, interpreter).
Testée avec des scénarios simples et complexes.

-Variables :
Déclaration et assignation de variables.
Gestion de différents types (int, bool, instances de classes).
Fonctionnalité testée à travers des cas variés.

-Instructions :
Structures de contrôle prises en charge :
Instructions conditionnelles if-else.
Boucles while.
Instructions return.
Fonctionne avec des flux de contrôle imbriqués.

-Classes et attributs :
Support pour la définition des classes avec attributs et méthodes.
Gestion des modificateurs de visibilité (public, protected, private) et des attributs final.
Héritage des attributs avec vérification des conflits.

-Méthodes :
Support pour la définition et l’appel des méthodes, y compris les constructeurs.
Les méthodes respectent les règles de visibilité et les vérifications des paramètres.
Compatibilité entre les signatures des méthodes héritées et les méthodes des classes filles.

-Héritage :
Support de l’héritage simple avec gestion des relations parent-enfant.
Les méthodes et attributs hérités respectent les règles de visibilité et d’accès.

## Extensions

-Déclarations en série :
Possibilité de déclarer plusieurs variables en une seule instruction (exemple : var int a, b, c;).
Implémenté dans kawaparser et testé dans tous les composants.

-Opérateur instanceof :
Ajout du test dynamique permettant de vérifier si un objet est une instance (ou sous-type) d'une classe.
Intégré dans kawaparser, typechecker et interpreter.

-Modificateurs de visibilité :
Les attributs et les méthodes peuvent être marqués comme public, protected ou private.
Les règles de visibilité sont appliquées au niveau du typechecker et du interpreter.
Tests étendus pour garantir le respect des restrictions d’accès.

-Attributs final :
Les attributs marqués comme final doivent être initialisés dans le constructeur et ne peuvent pas être réassignés.
Vérifications ajoutées dans le typechecker pour assurer ce comportement.
Cas d’utilisation testés, y compris pour les attributs hérités.

-----------------------------
# Processus d’implémentation
-----------------------------

L’implémentation a suivi une approche méthodique, ligne par ligne, comme indiqué dans le tableau fourni.
 Chaque fonctionnalité a été d'abord ajoutée au lexer, puis analysée dans le parser, validée par le typechecker, et enfin exécutée dans l’interpréteur.
  Des tests ont été réalisés à chaque étape pour vérifier le bon fonctionnement.

-------------------------
# Problèmes rencontrés
-------------------------
-Gestion de l'héritage : La fusion des attributs et méthodes des classes parentes et enfants a nécessité une gestion fine, notamment pour vérifier la cohérence des types.

-Vérificateur de types : La complexité des règles de typage pour l'héritage et les extensions a nécessité des ajustements dans le typechecker.

-Problèmes de syntaxe : Plusieurs erreurs dans le fichier kawaparser.mly ont dû être corrigées, notamment pour gérer les nouvelles extensions (extends,.. etc.).

-Règles de visibilité :
La gestion des modificateurs public, protected, et private a nécessité une gestion minutieuse des hiérarchies de classes.
Le débogage a été complexe, en particulier pour les accès aux attributs dans les sous-classes.

-Opérateur instanceof :
La vérification dynamique des types des objets a posé des défis, notamment avec les relations d’héritage.
Des tests approfondis ont été nécessaires pour couvrir tous les cas possibles.

-Attributs final :
Imposer la règle selon laquelle les attributs final doivent être initialisés dans le constructeur et ne peuvent pas être réassignés a nécessité une gestion spécifique dans le typechecker.
Les cas impliquant des attributs final hérités ont ajouté de la complexité.

-Combinaison des extensions :
L’intégration de plusieurs extensions (e.g., visibilité et attributs final) tout en maintenant la cohérence avec l’héritage a nécessité des ajustements importants.

----------------------
# Tests et validation
----------------------
Des tests ont été réalisés pour chaque fonctionnalité, ligne par ligne, comme illustré dans le tableau ci-dessous :

Fonctionnalité	            kawalexer	kawaparser	typechecker	interpreter
Opérations arithmétiques	    ✅	    ✅	        ✅	        ✅
Variables	                    ✅	    ✅	        ✅	        ✅
Instructions	                ✅	    ✅	        ✅	        ✅
Classes et attributs	        ✅	    ✅	        ✅	        ✅
Méthodes	                    ✅	    ✅	        ✅	        ✅
Héritage	                    ✅	    ✅	        ✅	        ✅
Déclarations en série	        ✅	    ✅	        ✅	        ✅
Opérateur instanceof	        ✅	    ✅	        ✅	        ✅
Modificateurs de visibilité	    ✅	    ✅	        ✅	        ✅
Attributs final	                ✅	    ✅	        ✅	        ✅


-----------------------
# Limitations Actuelles
-----------------------
Optimisation : Le code pourrait être optimisé pour réduire la duplication et améliorer la lisibilité.

-------------
# Conclusion
-------------
Le projet implémente avec succès les fonctionnalités de base du langage Kawa, ainsi que plusieurs extensions. Tous les composants ont été rigoureusement testés, et la majorité des fonctionnalités fonctionnent comme prévu. Les extensions (déclaration en série, instanceof, visibilité, attributs final) ont enrichi le langage, bien qu’elles aient introduit des défis supplémentaires.














