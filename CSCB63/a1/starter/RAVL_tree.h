/*
 *  Header file for our RAVL (augmented with Rank AVL) tree implementation.
 *
 *  Author: Anya Tafliovich.
 *  Based on materials developed by F. Estrada.
 *
 *  You will NOT be submitting this file. Your code will be tested with the
 *  original version of this file, so make sure you do not modify it!
*/

#include<stdio.h>
#include<stdlib.h>

#ifndef __RAVL_tree_header
#define __RAVL_tree_header

#define NOTIN -1

typedef struct ravl_node {
  int key;                 // key stored in this node
  void* value;             // value associated with this node's key
  int height;              // height of tree rooted at this node
  int size;               // size of tree rooted at this node
  struct ravl_node* left;   // this node's left child
  struct ravl_node* right;  // this node's right child
} RAVL_Node;

/* Returns the node, from the tree rooted at 'node', that contains key 'key'.
 * Returns NULL if 'key' is not in the tree.
*/
RAVL_Node* search(RAVL_Node* node, int key);

/* Inserts the key/value pair 'key'/'value' into the RAVL tree rooted at
 * 'node'.  If 'key' is already a key in the tree, updates the value
 * associated with 'key' to 'value'. Returns the root of the resulting tree.
 */
RAVL_Node* insert(RAVL_Node* node, int key, void* value);

/* Deletes the node with key 'key' from the RAVL tree rooted at 'node'.  If
 * 'key' is not a key in the tree, the tree is unchanged. Returns the root of
 * the resulting tree.
*/
RAVL_Node* delete(RAVL_Node* node, int key);

/* Returns the rank of the node, from the tree rooted at 'node', that
 * contains key 'key'.  Returns NOTIN if 'key' is not in the tree.
*/
int rank(RAVL_Node* node, int key);

/* Returns the node, from the tree rooted at 'node', that has rank 'rank'.
 * Returns NULL if there is no node with rank 'rank' in the tree.
*/
RAVL_Node* findRank(RAVL_Node* node, int rank);

/* Prints the keys of the RAVL tree rooted at 'node', in the in-order
 * traversal order.
 */
void printTreeInorder(RAVL_Node* node);

/* Frees all memory allocated for an RAVL tree rooted at 'node'.
 */
void deleteTree(RAVL_Node* node);

#endif
