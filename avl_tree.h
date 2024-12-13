#include <stdio.h>
#ifndef AVL_TREE_H
#define AVL_TREE_H

typedef struct AVLNode {
    long station_id;        // Identifiant unique de la station
    long capacity;          // Capacité maximale de la station (kWh)
    long total_consumption; // Somme des consommations connectées
    long height;            // Hauteur du nœud
    struct AVLNode *left, *right; // Pointeurs vers les sous-arbres
} AVLNode;

// Prototypes des fonctions AVL
AVLNode* insert(AVLNode* root, long station_id, long capacity, long consumption);
void inorder_traversal(AVLNode* root, FILE* output_file);
void free_tree(AVLNode* root);

#endif