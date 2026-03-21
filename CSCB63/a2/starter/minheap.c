/*
 * Our min-heap implementation.
 *
 * Author (starter code): A. Tafliovich.
 */

#include "minheap.h"

#define ROOT_INDEX 1
#define NOTHING -1

/*************************************************************************
 ** Suggested helper functions -- to help designing your code
 *************************************************************************/
bool isValidIdx(MinHeap* heap, int nodeIndex){
    if (heap == NULL) return false;
    if(nodeIndex <= heap->size && nodeIndex >= ROOT_INDEX) return true;
    return false;
}
int leftIdx(MinHeap* heap, int nodeIndex){
    int left = 2 * nodeIndex;
    if (isValidIdx(heap, left) && isValidIdx(heap, nodeIndex)) return left;
    return NOTHING;
}
int rightIdx(MinHeap* heap, int nodeIndex){
    int right = 2 * nodeIndex + 1;;
    if (isValidIdx(heap, right) && isValidIdx(heap, nodeIndex)) return right;
    return NOTHING;
}
int parentIdx(MinHeap* heap, int nodeIndex){
    int parent = nodeIndex / 2;
    if (isValidIdx(heap, parent) && isValidIdx(heap, nodeIndex)) return parent;
    return NOTHING;
}
int priorityAt(MinHeap* heap, int nodeIndex){
    if (heap == NULL || !isValidIdx(heap, nodeIndex)){
        return NOTHING;
    }
    return heap->arr[nodeIndex].priority;
}
int idAt(MinHeap* heap, int nodeIndex){
    if (heap == NULL || !isValidIdx(heap, nodeIndex)){
        return NOTHING;
    }
    return heap->arr[nodeIndex].id;
}
int indexOf(MinHeap* heap, int id){
//    if ( heap == NULL || id < 0 || heap->indexMap[id] == NOTHING || id >= heap->capacity){
//        return NOTHING;
//    }
    return heap->indexMap[id];
}
void swapHeapNodes(HeapNode* big, HeapNode* small) {
    HeapNode temp = *big;
    *big = *small;
    *small = temp;
}
void getMinHeapDone(MinHeap* heap, int index) {
    if (heap == NULL) return;
    int doingDex = index;
    int left = leftIdx(heap, index);
    int right = rightIdx(heap, index);
    if (isValidIdx(heap,right) && heap->arr[right].priority < heap->arr[doingDex].priority) {
        doingDex = right;
    }
    if (isValidIdx(heap,left) && heap->arr[left].priority < heap->arr[doingDex].priority) {
        doingDex = left;
    }
    if (doingDex != index) {
        swapHeapNodes(&heap->arr[index], &heap->arr[doingDex]);
        heap->indexMap[heap->arr[index].id] = index;
        heap->indexMap[heap->arr[doingDex].id] = doingDex;
        getMinHeapDone(heap, doingDex);
    }
}
MinHeap* newHeap(int capacity) {
    MinHeap* pHeap = malloc(sizeof(MinHeap));
    pHeap->arr = (HeapNode*)malloc(capacity * sizeof(HeapNode));
    pHeap->size = 0;
    pHeap->indexMap = (int*)malloc(capacity * sizeof(int));
    pHeap->capacity = capacity;
    for (int i = 0; i < capacity; i++) {
        pHeap->indexMap[i] = -1;
    }
    return pHeap;
}
void deleteHeap(MinHeap* heap) {
    free(heap->arr);
    free(heap->indexMap);
    free(heap);
}

bool isUnique(MinHeap* heap, int id){
    for(int i = 0; i < heap->size; i++){
        if(heap->arr[i].id == id){
            return false;
        }
    }
    return true;
}
void bubbleDown(MinHeap* heap, int size){

    while (size != 0 && heap->arr[parentIdx(heap, size)].priority > heap->arr[size].priority) {
        swapHeapNodes(&heap->arr[size], &heap->arr[parentIdx(heap, size)]);
        heap->indexMap[heap->arr[size].id] = size;
        heap->indexMap[heap->arr[parentIdx(heap, size)].id] = parentIdx(heap, size);
        size = parentIdx(heap, size);
    }
}
void bubbleUp(MinHeap* heap, int nodeIndex){
    while (nodeIndex != 0 && heap->arr[parentIdx(heap, nodeIndex)].priority > heap->arr[nodeIndex].priority) {
        swapHeapNodes(&heap->arr[nodeIndex], &heap->arr[parentIdx(heap, nodeIndex)]);
        heap->indexMap[heap->arr[nodeIndex].id] = nodeIndex;
        heap->indexMap[heap->arr[parentIdx(heap, nodeIndex)].id] = parentIdx(heap, nodeIndex);
        nodeIndex = parentIdx(heap, nodeIndex);
    }
}
/*********************************************************************
 * Required functions
 ********************************************************************/
HeapNode getMin(MinHeap* heap) {
    if (heap->size == 0) {
        HeapNode node = { .priority = -1, .id = -1 };
        return node;
    }
    return heap->arr[ROOT_INDEX];
}

HeapNode extractMin(MinHeap* heap) {
    if (heap->size == 0) {
        HeapNode node = { .priority = -1, .id = -1 };
        return node;
    }
    HeapNode min = heap->arr[ROOT_INDEX];
    heap->arr[ROOT_INDEX] = heap->arr[heap->size - 1];
    heap->indexMap[heap->arr[ROOT_INDEX].id] = ROOT_INDEX;
    heap->size = heap->size -1;
    getMinHeapDone(heap, ROOT_INDEX);
    int id = min.id;
    heap->indexMap[id] = 0;
    heap->arr[heap->size+1].id = 0;
    heap->arr[heap->size+1].priority = 0;
    return min;
}
void insert(MinHeap* heap, int priority, int id) {
    if (heap->size > heap->capacity) {
        return;
    }
    int size = heap->size + 1;
    heap->arr[size].priority = priority;
    heap->arr[size].id = id;
    heap->indexMap[id] = size;
    bubbleDown(heap, size);
    heap->size = heap->size + 1;
}

bool decreasePriority(MinHeap* heap, int id, int newPriority) {
    int nodeIndex = heap->indexMap[id];
    if (nodeIndex == -1) {
        return false;
    }
    if (heap->arr[nodeIndex].priority <= newPriority) {
        return false;
    }
    heap->arr[nodeIndex].priority = newPriority;
    bubbleUp(heap, nodeIndex);
    return true;
}

/*********************************************************************
 ** Helper function provided
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
