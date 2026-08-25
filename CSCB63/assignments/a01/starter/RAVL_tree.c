/*
 *  RAVL (augmented with Rank AVL) tree implementation.
 *  Author (starter code): Anya Tafliovich.
 *  Based on materials developed by F. Estrada.
*/

#include "RAVL_tree.h"

/*************************************************************************
 ** Suggested helper functions
 *************************************************************************/

/* Returns the height (number of nodes on the longest root-to-leaf path) of
 * the tree rooted at node 'node'. Returns 0 if 'node' is NULL.  Note: this
 * should be an O(1) operation.
 */
int height(RAVL_Node *node) {
    if (node != NULL) {
        return node->height;
    }
    return 0;
}

/* Returns the size (number of nodes) of the tree rooted at node 'node'.
 * Returns 0 if 'node' is NULL.  Note: this should be an O(1) operation.
 */
int size(RAVL_Node *node) {
    if (node != NULL) {
        return node->size;
    }
    return 0;
}

/* Updates the height of the tree rooted at node 'node' based on the heights
 * of its children. Note: this should be an O(1) operation.
 */
void updateHeight(RAVL_Node *node) {
    if (node != NULL) {
        int lh = height(node->left);
        int rg = height(node->right);
        if (lh > rg) {
            node->height = lh + 1;
        } else {
            node->height = rg + 1;
        }
    }

}

/* Updates the size of the tree rooted at node 'node' based on the sizes
 * of its children. Note: this should be an O(1) operation.
 */
void updateSize(RAVL_Node *node) {
    if (node != NULL) {
        int ls = size(node->left);
        int rs = size(node->right);
        node->size = ls + rs + 1;
    }

}

/* Returns the balance factor (height of left subtree - height of right
 * subtree) of node 'node'. Returns 0 if node is NULL.  Note: this should be
 * an O(1) operation.
 */
int balanceFactor(RAVL_Node *node) {
    if (node == NULL) return 0;
    return height(node->left) - height(node->right);
}

/* Returns the result of performing the corresponding rotation in the RAVL
 * tree rooted at 'node'.
 */

// single rotations: right/clockwise
RAVL_Node *rightRotation(RAVL_Node *node) {
    RAVL_Node *l_node, *l_node_r;
    l_node = node->left;
    l_node_r = l_node->right;

    l_node->right = node;
    node->left = l_node_r;

    updateHeight(node);
    updateHeight(l_node);
    updateHeight(l_node_r);

    updateSize(node);
    updateSize(l_node);
    updateSize(l_node_r);

    return l_node;
}

// single rotations: left/counter-clockwise
RAVL_Node *leftRotation(RAVL_Node *node) {
    RAVL_Node *r_node, *r_node_l;
    r_node = node->right;
    r_node_l = r_node->left;

    r_node->left = node;
    node->right = r_node_l;

    updateHeight(node);
    updateHeight(r_node);
    updateHeight(r_node_l);

    updateSize(node);
    updateSize(r_node);
    updateSize(r_node_l);

    return r_node;

}

// double rotation: right/clockwise then left/counter-clockwise
RAVL_Node *rightLeftRotation(RAVL_Node *node);

// double rotation: left/counter-clockwise then right/clockwise
RAVL_Node *leftRightRotation(RAVL_Node *node);


//Double rotation: left/counter-clockwise then right/clockwise
// OR right/clockwise then left/counter-clockwise
RAVL_Node *DoubleRotation(RAVL_Node *node) {
    int bf = balanceFactor(node);
    if (bf < -1) {
        if (balanceFactor(node->right) <= 0) {
            return leftRotation(node);
        } else {
            node->right = rightRotation(node->right);
            return leftRotation(node);
        }
    }
    if (bf > 1) {
        if (balanceFactor(node->left) >= 0) {
            return rightRotation(node);
        } else {
            node->left = leftRotation(node->left);
            return rightRotation(node);
        }
    }
    return node;
}

/* Returns the successor node of 'node'. */
RAVL_Node *successor(RAVL_Node *node);


/* Creates and returns an RAVL tree node with key 'key', value 'value', height
 * and size of 1, and left and right subtrees NULL.
 */
RAVL_Node *createNode(int key, void *value) {
    RAVL_Node *node = NULL;

    node = (RAVL_Node *) malloc(sizeof(RAVL_Node));
    node->key = key;
    node->value = value;
    node->height = 1;
    node->size = 1;
    node->left = NULL;
    node->right = NULL;
    return node;
}

/*************************************************************************
 ** Provided functions
 *************************************************************************/

void printTreeInorder_(RAVL_Node *node, int offset) {
    if (node == NULL) return;
    printTreeInorder_(node->right, offset + 1);
    printf("%*s %d [%d / %d]\n", offset, "", node->key, node->height, node->size);
    printTreeInorder_(node->left, offset + 1);
}

void printTreeInorder(RAVL_Node *node) {
    printTreeInorder_(node, 0);
}

void deleteTree(RAVL_Node *node) {
    if (node == NULL) return;
    deleteTree(node->left);
    deleteTree(node->right);
    free(node);
}

/*************************************************************************
 ** Required functions
 ** Must run in O(log n) where n is the number of nodes in a tree rooted
 **  at 'node'.
 *************************************************************************/

RAVL_Node *search(RAVL_Node *node, int key) {
    if (node == NULL) return NULL;
    if (node->key < key) {
        return search(node->right, key);
    } else if (node->key > key) {
        return search(node->left, key);
    }else{
        return node;
    }
}

RAVL_Node *insert(RAVL_Node *node, int key, void *value) {
    if (node == NULL) {
        return createNode(key, value);
    }
    if (key < node->key) {
        node->left = insert(node->left, key, value);
    } else if (key > node->key) {
        node->right = insert(node->right, key, value);
    } else {
        return node;
    }

    updateHeight(node);
    updateSize(node);
    node = DoubleRotation(node);

    return node;
}

RAVL_Node *delete(RAVL_Node *node, int key) {
    RAVL_Node *child;
    if (node == NULL) {
        return NULL;
    }
    if (key < node->key) {
        node->left = delete(node->left, key);
    } else if (key > node->key) {
        node->right = delete(node->right, key);
    } else {
        if (node->left == NULL || node->right == NULL) {
            child = node->left;
            if (node->right != NULL) {
                child = node->right;
            }
            if (child == NULL) {
                free(node);
                return NULL;
            } else {
                free(node);
                updateHeight(child);
                updateSize(child);
                child = DoubleRotation(child);
                return child;
            }
        } else {
            RAVL_Node *temp = node->right;
            while (temp->left != NULL) {
                temp = temp->left;
            }
            int tempVal = temp->key;
            void *tem = temp->value;
            node->right = delete(node->right, temp->key);
            node->key = tempVal;
            node->value = tem;
        }
    }
 
    updateHeight(node);
    updateSize(node);
    node = DoubleRotation(node);
    return node;
}

int rank(RAVL_Node *node, int key) {
    if (node == NULL) return NOTIN;
    if (node->key == key) return size(node->left) + 1;
    if (key > node->key) {
        return size(node->left) + 1 + rank(node->right, key);
    } else {
        return rank(node->left, key);
    }

}

RAVL_Node *findRank(RAVL_Node *node, int rank) {
    if (node == NULL) return NULL;
    int l_rank = size(node->left) + 1;
    if (l_rank == rank) return node;
    if (rank < l_rank) {
        return findRank(node->left, rank);
    } else {
        return findRank(node->right, rank - l_rank);
    }
}
