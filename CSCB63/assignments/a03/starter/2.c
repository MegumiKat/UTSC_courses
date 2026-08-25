/*
 * Our min-heap implementation.
 *
 * Author (starter code): A. Tafliovich.
 */

#include "minheap.h"

#define ROOT_INDEX 1
#define NOTHING -1

/*************************************************************************
 ** Suggested helper functions -- part of starter code
 *************************************************************************/

/* Returns True if 'maybeIdx' is a valid index in minheap 'heap', and 'heap'
 * stores an element at that index. Returns False otherwise.
 */
bool isValidIndex(MinHeap* heap, int maybeIdx){
       if (ROOT_INDEX <= maybeIdx && maybeIdx <= heap->size){
              return true;
       }
       return false;
}

/* Returns the index of the left child of a node at index 'nodeIndex' in
 * minheap 'heap', if such exists.  Returns NOTHING if there is no such left
 * child.
 */
int leftIdx(MinHeap* heap, int nodeIndex){
       if (isValidIndex(heap,2*nodeIndex)){
              return 2*nodeIndex;
       }
       return NOTHING;
}

/* Returns the index of the right child of a node at index 'nodeIndex' in
 * minheap 'heap', if such exists.  Returns NOTHING if there is no such right
 * child.
 */
int rightIdx(MinHeap* heap, int nodeIndex){
       if(isValidIndex(heap,2*nodeIndex+1)){
              return 2*nodeIndex + 1;
       }
       return NOTHING;
}

/* Returns the index of the parent of a node at index 'nodeIndex' in minheap
 * 'heap', if such exists.  Returns NOTHING if there is no such parent.
 */
int parentIdx(MinHeap* heap, int nodeIndex){
       if(isValidIndex(heap,nodeIndex/2)){
              return nodeIndex/2;
       }
       return NOTHING;
}

/* Swaps contents of heap->arr[index1] and heap->arr[index2] if both 'index1'
 * and 'index2' are valid indices for minheap 'heap'. Has no effect
 * otherwise.
 */
void swap(MinHeap* heap, int index1, int index2){
       int max = heap->size + 1;
       if(index1 <= max && index2 <= max){
              int id1, id2;
              id1 = heap->arr[index1].id;
              id2 = heap->arr[index2].id;
              heap->indexMap[id1] = index2;
              heap->indexMap[id2] = index1;
              HeapNode temp;
              temp = heap->arr[index1];
              heap->arr[index1] = heap->arr[index2];
              heap->arr[index2] = temp;
       }
}

/* Bubbles up the element newly inserted into minheap 'heap' at index
 * 'nodeIndex', if 'nodeIndex' is a valid index for heap. Has no effect
 * otherwise.
 */
void bubbleUp(MinHeap* heap, int nodeIndex){
       int parent = parentIdx(heap,nodeIndex);
       if(parent == NOTHING) return;
       if(heap->arr[nodeIndex].priority < heap->arr[parent].priority){
              swap(heap,nodeIndex,parent);
              bubbleUp(heap,parent);
       }
}

int minnode(MinHeap* heap, int leftnode, int rightnode){
       if (heap->arr[leftnode].priority < heap->arr[rightnode].priority){
              return leftnode;
       }
       return rightnode;
}

/* Bubbles down the element newly inserted into minheap 'heap' at the root,
 * if it exists. Has no effect otherwise.
 */
void bubbleDown(MinHeap* heap, int nodeIndex){
       int left = leftIdx(heap,nodeIndex);
       int right = rightIdx(heap,nodeIndex);
       if(isValidIndex(heap,left) && isValidIndex(heap,right)){
              int min = minnode(heap,left,right);
              if(minnode(heap,min,nodeIndex) != nodeIndex){
                     swap(heap,nodeIndex,min);
                     bubbleDown(heap,min);
              }
       }else if (isValidIndex(heap,left) && !isValidIndex(heap,right) && heap->arr[left].priority < heap->arr[nodeIndex].priority){
              swap(heap,nodeIndex,left);
              bubbleDown(heap,left);
       }
       return;
}

/* Returns node at index 'nodeIndex' in minheap 'heap'.
 * Precondition: 'nodeIndex' is a valid index in 'heap'
 *               'heap' is non-empty
 */
HeapNode nodeAt(MinHeap* heap, int nodeIndex){
       return heap->arr[nodeIndex];
}

/* Returns priority of node at index 'nodeIndex' in minheap 'heap'.
 * Precondition: 'nodeIndex' is a valid index in 'heap'
 *               'heap' is non-empty
 */
int priorityAt(MinHeap* heap, int nodeIndex){
       return heap->arr[nodeIndex].priority;
}

/* Returns ID of node at index 'nodeIndex' in minheap 'heap'.
 * Precondition: 'nodeIndex' is a valid index in 'heap'
 *               'heap' is non-empty
 */
int idAt(MinHeap* heap, int nodeIndex){
       return heap->arr[nodeIndex].id;
}

/* Returns index of node with ID 'id' in minheap 'heap'.
 * Precondition: 'id' is a valid ID in 'heap'
 *               'heap' is non-empty
 */
int indexOf(MinHeap* heap, int id){
       return heap->indexMap[id];
}

/*********************************************************************
 * Required functions
 ********************************************************************/

void deleteHeap(MinHeap* heap){
       free(heap->arr);
       free(heap->indexMap);
       free(heap);
}

HeapNode getMin(MinHeap* heap){
       return heap->arr[ROOT_INDEX];
}

MinHeap* newHeap(int capacity){
       MinHeap *heap = (MinHeap *)malloc(sizeof(MinHeap));
       heap->size = 0;
       heap->capacity = capacity;
       heap->arr = (HeapNode *)malloc(sizeof(HeapNode)*(capacity + 1));
       heap->indexMap = (int *)malloc(sizeof(int) * (capacity + 1));
       return heap;
}

void insert(MinHeap* heap, int priority, int id){
       HeapNode node;
       node.id = id;
       node.priority = priority;
       int newsize = heap->size + 1;
       heap->arr[newsize] = node;
       heap->size = newsize;
       heap->indexMap[id] = newsize;
       bubbleUp(heap,newsize);
}

HeapNode extractMin(MinHeap* heap){
       HeapNode min = getMin(heap);
       heap->arr[ROOT_INDEX] = heap->arr[heap->size];  
       heap->indexMap[heap->arr[ROOT_INDEX].id] = ROOT_INDEX;
       heap->size = heap->size - 1;
       bubbleDown(heap,ROOT_INDEX);
       HeapNode node;
       heap->arr[heap->size + 1].id = 0;
       heap->arr[heap->size + 1].priority = 0;
       heap->indexMap[min.id] = 0;
       return min;
}

int getPriority(MinHeap* heap, int id){
       int nodeindex = indexOf(heap,id);
       return priorityAt(heap,nodeindex);
}

bool decreasePriority(MinHeap* heap, int id, int newPriority){
       int nodeindex = indexOf(heap,id);
       if(heap->arr[nodeindex].priority <= newPriority || !isValidIndex(heap,nodeindex)){
              return false;
       }
       heap->arr[nodeindex].priority = newPriority;
       bubbleUp(heap,nodeindex);
       return true;
}



/*********************************************************************
 ** Helper function provided in the starter code
 *********************************************************************/
void printHeap(MinHeap* heap) {
  printf("MinHeap with size: %d\n\tcapacity: %d\n\n", heap->size,
         heap->capacity);
  printf("index: priority [ID]\t ID: index\n");
  for (int i = 0; i < heap->capacity; i++)
    printf("%d: %d [%d]\t\t%d: %d\n", i, priorityAt(heap, i), idAt(heap, i), i,
           indexOf(heap, i));
  printf("%d: %d [%d]\t\t\n", heap->capacity, priorityAt(heap, heap->capacity),
         idAt(heap, heap->capacity));
  printf("\n\n");
}
