Pokedex App - README

Description

Cette application Pokedex permet à l'utilisateur de consulter une liste de Pokémon, de les filtrer par type, de les trier par différents critères (nom, attaque, points de vie), et de les marquer comme favoris. En outre, l'application envoie des notifications locales pour rappeler à l'utilisateur de découvrir un Pokémon aléatoire chaque jour, ainsi que des notifications lorsqu'un Pokémon favori change de type. Vous pouvez également zoomer sur un Pokémon pour voir ses détails, et une animation est présente lorsque vous ajoutez ou retirez un Pokémon de vos favoris.

Fonctionnalités principales

Affichage de la liste des Pokémon :
L'application récupère les Pokémon via l'API PokeAPI et les affiche sous forme de liste.
Chaque Pokémon est accompagné de son image et de ses informations (nom, type, etc.).
Filtres :
Possibilité de filtrer la liste des Pokémon par type (par exemple, "Feu", "Eau", "Normal", etc.).
Recherche par nom de Pokémon à l'aide d'une barre de recherche.
Tri des Pokémon :
Tri des Pokémon par nom, attaque, ou points de vie (en ordre croissant ou décroissant).
Favoris :
L'utilisateur peut ajouter ou supprimer des Pokémon de ses favoris.
Un bouton cœur permet de marquer un Pokémon comme favori. Lorsqu'un Pokémon est ajouté ou retiré des favoris, une animation d'agrandissement du cœur est affichée pour indiquer l'action.
Zoom sur un Pokémon :
Lorsqu'un utilisateur clique sur un Pokémon, il peut voir une vue détaillée avec un effet de zoom-in ou zoom-out pour une meilleure expérience visuelle.
Notifications locales :
Notification quotidienne : Chaque jour à 8h, l'utilisateur reçoit une notification pour découvrir un Pokémon aléatoire.
Changement de type d'un Pokémon favori : Lorsqu'un Pokémon favori change de type (simulé de manière aléatoire), une notification informe l'utilisateur du changement.
Fonctionnalités supplémentaires

Page des favoris :
Une page dédiée qui affiche uniquement les Pokémon favoris de l'utilisateur. Cette page permet de mieux gérer les Pokémon favoris séparément des autres.
Animations :
Animation du cœur : Lorsqu'un utilisateur clique sur un Pokémon pour l'ajouter ou le retirer de ses favoris, un effet d'animation est affiché sur le cœur (agrandissement ou rétrécissement) pour rendre l'interaction plus visuelle et dynamique.
Zoom-in / Zoom-out : Un effet de zoom est appliqué lorsque l'utilisateur clique sur un Pokémon pour afficher ses détails. Cela permet à l'utilisateur de mieux apprécier l'image et les informations du Pokémon.
Permissions pour notifications : Lors du démarrage de l'application, une demande de permission pour les notifications locales est envoyée à l'utilisateur.
Simuler un changement de type :
Un Pokémon favori peut voir son type changé de manière aléatoire parmi un ensemble de types (par exemple, "Feu", "Eau", "Plante", "Électrique").
Une notification est envoyée pour informer l'utilisateur du changement de type du Pokémon favori.
