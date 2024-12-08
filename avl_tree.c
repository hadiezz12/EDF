#include "avl_tree.h"
#include <stdlib.h>
#include <stdio.h>

// Utilitaires
int height(AVLNode* node) {
    return node ? node->height : 0;
}

int max(int a, int b) {
    return (a > b) ? a : b;
}

// Crée un nouveau nœud AVL
AVLNode* create_node(int station_id, int capacity, int consumption) {
    AVLNode* node = (AVLNode*)malloc(sizeof(AVLNode));
    if (!node) {
        perror("Error allocating memory for AVLNode");
        exit(1);
    }
    node->station_id = station_id;
    node->capacity = capacity;
    node->total_consumption = consumption;
    node->height = 1; // Nouveau nœud est une feuille
    node->left = node->right = NULL;
    return node;
}

// Rotation droite
AVLNode* rotate_right(AVLNode* y) {
    AVLNode* x = y->left;
    AVLNode* T = x->right;

    x->right = y;
    y->left = T;

    y->height = max(height(y->left), height(y->right)) + 1;
    x->height = max(height(x->left), height(x->right)) + 1;

    return x;
}

// Rotation gauche
AVLNode* rotate_left(AVLNode* x) {
    AVLNode* y = x->right;
    AVLNode* T = y->left;

    y->left = x;
    x->right = T;

    x->height = max(height(x->left), height(x->right)) + 1;
    y->height = max(height(y->left), height(y->right)) + 1;

    return y;
}

// Calcul du facteur d'équilibre
int balance_factor(AVLNode* node) {
    return node ? height(node->left) - height(node->right) : 0;
}

// Insertion dans l'arbre AVL
AVLNode* insert(AVLNode* root, int station_id, int capacity, int consumption) {
    if (!root) {
        return create_node(station_id, capacity, consumption);
    }

    if (station_id < root->station_id) {
        root->left = insert(root->left, station_id, capacity, consumption);
    } else if (station_id > root->station_id) {
        root->right = insert(root->right, station_id, capacity, consumption);
    } else {
        // Mise à jour de la consommation totale et de la capacité maximale
        root->total_consumption += consumption;
        root->capacity = max(root->capacity, capacity);
        return root;
    }

    // Mise à jour de la hauteur
    root->height = max(height(root->left), height(root->right)) + 1;

    // Rééquilibrage
    int balance = balance_factor(root);

    // Cas d'équilibre
    if (balance > 1 && station_id < root->left->station_id) {
        return rotate_right(root);
    }

    if (balance < -1 && station_id > root->right->station_id) {
        return rotate_left(root);
    }

    if (balance > 1 && station_id > root->left->station_id) {
        root->left = rotate_left(root->left);
        return rotate_right(root);
    }

    if (balance < -1 && station_id < root->right->station_id) {
        root->right = rotate_right(root->right);
        return rotate_left(root);
    }
    printf("DEBUG: Inserting station ID %d with capacity %d and consumption %d\n", station_id, capacity, consumption);
    return root;
}

// Parcours en ordre croissant et écriture dans le fichier de sortie
void inorder_traversal(AVLNode* root, FILE* output_file) {
    if (!root) return;

    inorder_traversal(root->left, output_file);
    fprintf(output_file, "%d:%d:%d\n", root->station_id, root->capacity, root->total_consumption);
    inorder_traversal(root->right, output_file);
}

// Libère la mémoire de l'arbre
void free_tree(AVLNode* root) {
    if (!root) return;

    free_tree(root->left);
    free_tree(root->right);
    free(root);
}