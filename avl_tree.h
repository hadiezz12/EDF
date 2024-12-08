#include <stdio.h>
#ifndef AVL_TREE_H
#define AVL_TREE_H

typedef struct AVLNode {
    int station_id;        // Identifiant unique de la station
    int capacity;          // Capacité maximale de la station (kWh)
    int total_consumption; // Somme des consommations connectées
    int height;            // Hauteur du nœud
    struct AVLNode *left, *right; // Pointeurs vers les sous-arbres
} AVLNode;

// Prototypes des fonctions AVL
AVLNode* insert(AVLNode* root, int station_id, int capacity, int consumption);
void inorder_traversal(AVLNode* root, FILE* output_file);
void free_tree(AVLNode* root);

#endif