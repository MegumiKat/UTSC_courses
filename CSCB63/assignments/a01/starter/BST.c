//
// Created by Mark on 2024-01-31.
//
#include<stdio.h>
#include<stdlib.h>
#include"NoteSynth.c"

typedef struct BST_Node_Struct
{
    // This compound type stores all data for one node of the
    // BST. Since the BST is used to store musical notes,
    // the data contained here represents one note from a
    // musical score:
    // freq: A double-precision floating point value,
    //       corresponding to the frequency (pitch) of the note
    // bar: Musical scores are divided into 'bars' (which you can
    //      see are actually separated by a vertical bar!). This
    //      value indicates which bar the note happens in. The
    //      first bar in the musical score is 0
    // index: Position of the note within the bar, from 0 (at the
    //        beginning of the bar) to 1 (at the end of the bar)
    // key: A unique identifier (remember we discussed BST nodes
    //      should have unique keys to identify each node). We
    //      want our nodes to store notes in the order in which
    //      they occur in the song. So, the key identifier is
    //      created as: key = (10.0*bar)+index
    //      NOTE: This means only one note can have a specific
    //            bar,index value. If two notes should happen
    //            at the same time in the song, we make the
    //            index of one of them a tiny bit bigger or
    //            a tiny bit smaller than the other one so
    //            their keys are very close, but not identical.

    double key;
    double freq;
    int bar;
    double index;
    struct BST_Node_Struct *left;
    struct BST_Node_Struct *right;
    /*** TO DO:
     * Complete the definition of the BST_Node_Struct
     ***/

} BST_Node;

BST_Node *newBST_Node(double freq, int bar, double index)
{
    /*
     * This function creates and initializes a new BST_Node
     * for a note with the given position (bar:index) and
     * the specified frequency. The key value for the node
     * is computed here as
     *
     * 		(10.0*bar)+index
     */

    /*** TO DO:
     * Complete this function to allocate and initialize a
     * new BST_Node. You should make sure the function sets
     * initial values for the data correctly.
     ****/
    BST_Node *new_review=NULL;
    new_review = (BST_Node *)calloc(1, sizeof(BST_Node));
    new_review->freq = freq;
    new_review->bar = bar;
    new_review->index = index;
    new_review->key = (10.0 * bar) + index;
    new_review->right = NULL;
    new_review->left = NULL;
    return new_review;
}

BST_Node *BST_insert(BST_Node *root, BST_Node *new_node)
{
    /*
     * This function inserts a new node into the BST. The
     * node must already have been initialized with valid
     * note data, and must have its unique key.
     *
     * The insert function must check that no other node
     * exists in the BST with the same key. If a node with
     * the same key exists, it must print out a message
     * using the following format string
     *
     * printf("Duplicate node requested (bar:index)=%d,%lf, it was ignored\n",....);
     * (of course you need to provide the relevant variables to print)
     *
     * And it must return without inserting anyting in the
     * BST.
     */

    /*** TO DO:
     * Implement the insert function so we can add notes to the tree!
     ****/
    if (root==NULL)
        return new_node;
    if (new_node->key < root->key)
    {
        root->left=BST_insert(root->left,new_node);
    } else if(new_node->key > root->key){
        root->right=BST_insert(root->right,new_node);
    }else{
        printf("Duplicate node requested (bar:index)=%d,%lf, it was ignored\n", new_node->bar, new_node->index);
    }
    return root;
}

BST_Node *BST_search(BST_Node *root, int bar, double index)
{
    /*
     * This function searches the BST for a note at the
     * specified position. If found, it must return a
     * pointer to the node that contains it.
     * Search has to happen according to the BST search
     * process - so you need to figure out what value to
     * use during the search process to decide which branch
     * of the tree to search next.
     */

    /*** TO DO:
     * Implement this function
     ****/
    double key = (10.0 * bar) + index;
    if(root == NULL) return NULL;
    if(root->key == key && root->bar == bar && root->index == index) {
        return root;
    }
    if (root->key > key)
    {
        return BST_search(root->left, bar, index);
    } else {
        return BST_search(root->right, bar, index);
    }
}

BST_Node *find_successor(BST_Node *right_child_node)
{
    /*
     * This function finds the successor of a node by
     * searching the right subtree for the node that
     * is most to the left (that will be the node
     * with the smallest key in that subtree)
     */

    /*** TO DO:
     * Implement this function
     ****/
    if(right_child_node == NULL)
        return NULL;
    right_child_node = right_child_node ->right;
    while(right_child_node->left != NULL){
        right_child_node = right_child_node->left;
    }
    return right_child_node;

}

BST_Node *BST_delete(BST_Node *root, int bar, double index)
{
    /*
     * Deletes from the BST a note at the specified position.
     * You must implement the three cases of BST deletion
     * we discussed in class. Make sure the function can
     * remove a note at any position without breaking the
     * tree!
     */

    /*** TO DO:
     * Implement this function
     ****/
    double key = (10.0 * bar) + index;
    BST_Node *tmp;
    if(root == NULL)
        return NULL;
    else if(root->key == key){
        if (root->left==NULL && root->right==NULL)
        {
            free(root);
            return NULL;
        }
        else if (root->right==NULL)
        {
            tmp =root->left;
            free(root);
            return tmp;
        }
        else if (root->left==NULL)
        {
            tmp=root->right;
            free(root);
            return tmp;
        } else {
            tmp = find_successor(root);
            root->key = tmp->key;
            root->index = tmp->index;
            root->bar = tmp ->bar;
            root->freq = tmp->freq;
            root->right = BST_delete(root->right, tmp->bar,tmp->index);
            return root;
        }
    }else if(key > root->key){
        root->right = BST_delete(root->right, bar, index);
    }else{
        root->left = BST_delete(root->left, bar, index);
    }
    return root;
}