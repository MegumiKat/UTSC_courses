/*
 *  Some light testing of out RAVL tree implementation. Note, that you will
 *  need to add your own, much more extensive, testing to ensure correctness
 *  of your code.
 *
 *  Author: Anya Tafliovich.
 *  Based on materials developed by F. Estrada.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "RAVL_tree.h"

#define MAX_LIMIT 1024

RAVL_Node* createTree(FILE* f);
void testTree(RAVL_Node* root);
void printTreeReport(RAVL_Node* root);

int main(int argc, char* argv[]) {
  RAVL_Node* root = NULL;

  // If user specified a file for reading, create a tree with keys from it.
  if (argc > 1) {
    FILE* f = fopen(argv[1], "r");
    if (f == NULL) {
      fprintf(stderr, "Unable to open the specified input file: %s\n", argv[1]);
      exit(0);
    }
    root = createTree(f);
    fclose(f);
  } else {
    printf("You did not specify an input file.");
    printf(" We will start with an empty tree.\n");
  }

  testTree(root);
  return 0;
}

RAVL_Node* createTree(FILE* f) {
  char line[MAX_LIMIT];
  int key;
  RAVL_Node* root = NULL;

  while (fgets(line, MAX_LIMIT, f)) {  // read the next line
    key = atoi(line);
    printf("read %d\n", key);
    root = insert(root, key, NULL);  // no values for this simple tester
    printTreeReport(root);
  }
  return root;
}

void testTree(RAVL_Node* root) {
  char line[1024];
  RAVL_Node* node;
  int r;

  while (1) {
    printf("Choose a command: (s)earch, (i)nsert, (d)elete, (r)ank, (f)ind rank, (q)uit\n");
    fgets(line, MAX_LIMIT, stdin);
    if (line[0] == 'q') {  // quit
      printf("Quit selected. Goodbye!\n");
      deleteTree(root);
      return;
    }
    if (line[0] == 's') {  // search
      printf("Search selected. Enter key to search for: ");
      fgets(line, MAX_LIMIT, stdin);
      node = search(root, atoi(line));
      if (node != NULL) {
        printf("Key %d was found at height %d, subtree size %d.\n", node->key, node->height, node->size);
      } else {
        printf("This key is not in the tree.\n");
      }
    } else if (line[0] == 'i') {  // insert
      printf("Insert selected. Enter key to insert");
      printf(" (no values in this simple tester): ");
      fgets(line, MAX_LIMIT, stdin);
      root = insert(root, atoi(line), NULL);
      printTreeReport(root);
    } else if (line[0] == 'd') {  // delete
      printf("Delete selected. Enter key to delete: ");
      fgets(line, MAX_LIMIT, stdin);
      root = delete(root, atoi(line));
      printTreeReport(root);
    } else if (line[0] == 'r') {  // rank
      printf("Rank selected. Enter key to search for: ");
      fgets(line, MAX_LIMIT, stdin);
      r = rank(root, atoi(line));
      if (r != NOTIN) {
        printf("This key has rank %d.\n", r);
      } else {
        printf("This key is not in the tree.\n");
      }
    } else if (line[0] == 'f') {  // find rank
      printf("Find rank selected. Enter rank to find: ");
      fgets(line, MAX_LIMIT, stdin);
      node = findRank(root, atoi(line));
      if (node != NULL) {
        printf("This rank was found in node with key %d, at height %d, subtree size %d.\n",
	       node->key, node->height, node->size);
      } else {
        printf("There is no node with this rank in the tree.\n");
      }
    }
  }
}

void printTreeReport(RAVL_Node* root) {
  printf("** The tree is now:\n");
  printTreeInorder(root);
  printf("**\n");
}
