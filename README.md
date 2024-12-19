# EDF
Installez les outils requis : GCC pour compilez et GNUPLOT pour le graphique 
Commandes pour acceder au fichier et compiler  :
1-cd 'project c'
2-cd codeC
3-make
4-cd ..
ensuite pour lancer/executer :
./c-wire.sh /<fichier de donner> <type de station> <type de consomateur>

Les différentes variables à connaître pour le bon déroulement du programme:
---

### `strtol`
`strtol` sert à convertir une chaîne en un nombre entier (`long`). On peut aussi récupérer ce qu’il reste après le nombre.  
**Exemple :**  
```c
char *str = "123abc";
char *end;
long num = strtol(str, &end, 10); // Convertit "123" en 123
```

### `perror`
`perror` affiche un message d'erreur clair sur la dernière erreur système (avec `errno`).  
**Exemple :**  
```c
FILE *f = fopen("test.txt", "r");
if (!f) {
    perror("Erreur d'ouverture"); // Affiche l'erreur
}
```

### `strncmp`
`strncmp` compare deux chaînes sur les `n` premiers caractères. Retourne 0 si elles sont identiques.  
**Exemple :**  
```c
if (strncmp("Bonjour", "Bon", 3) == 0) {
    printf("Identiques sur les 3 premiers caractères\n");
}


### `strtok`
`strtok` découpe une chaîne en morceaux ("tokens") selon un séparateur. Modifie la chaîne originale.  
**Exemple :**  
```c
char str[] = "a,b,c";
char *token = strtok(str, ",");
while (token) {
    printf("%s\n", token); // Affiche "a", "b", puis "c"
    token = strtok(NULL, ",");
}

Répartition des tâches:

William Bodjrenou-Masson : Partie C (AVL et traitement des données)
Hadi Ezzedine : Partie Shell (c-wire.sh)
Brayan Khalil : Documentation (README, PDF de présentation, tests et exemples d'exécutions)

But du projet :

Créer un programme qui analyse les données d’un système de distribution d’électricité en France. L’objectif est de voir si certaines stations produisent trop ou pas assez d’énergie et de savoir comment cette énergie est consommée (entreprises ou particuliers).

Intentions du projet :
Automatiser le traitement des données :
Gérer efficacement un grand volume de données en filtrant et structurant celles-ci à l'aide d'un script Shell et d'un programme en C.

Optimiser les performances :
Utiliser un arbre AVL pour réduire le temps de traitement et garantir une analyse rapide et fiable des données.

Offrir une solution flexible et générique :
Permettre à l'utilisateur de choisir les stations ou les catégories de consommateurs à analyser selon ses besoins.

Présenter des résultats exploitables :
Générer des fichiers CSV triés, lisibles et pertinents, ainsi que des graphiques pour une meilleure visualisation.

Renforcer les compétences techniques :
Apprendre à collaborer sur un projet complexe, à utiliser des outils professionnels comme GitHub, et à produire du code robuste et bien documenté.

