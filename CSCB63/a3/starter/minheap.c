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
bool isValidIdx(MinHeap* heap, int nodeIndex){
    if (heap == NULL) return false;
    if(nodeIndex <= heap->size + 1 && nodeIndex >= ROOT_INDEX) return true;
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
    return heap->arr[nodeIndex].priority;
}
int idAt(MinHeap* heap, int nodeIndex){
    return heap->arr[nodeIndex].id;
}
int indexOf(MinHeap* heap, int id){
    return heap->indexMap[id];
}
void swapNodes(MinHeap * heap, int index_1, int index_2) {
    if (index_2 <= heap->size + 1 && index_1 <= heap->size + 1){
        int id_1 = heap->arr[index_1].id;
        int id_2 = heap->arr[index_2].id;
        HeapNode temp = heap->arr[index_1];
        heap->arr[index_1] = heap->arr[index_2];
        heap->arr[index_2] = temp;
        heap->indexMap[id_1] = index_2;
        heap->indexMap[id_2] = index_1;
    }
}
void bubbleUp(MinHeap *heap, int nodeIndex){
    int parent = parentIdx(heap,nodeIndex);
    if(parent == NOTHING){
        return;
    }
    if(heap->arr[parent].priority > heap->arr[nodeIndex].priority){
        swapNodes(heap,parent,nodeIndex);
        bubbleUp(heap,parent);
        bubbleUp(heap, nodeIndex);
    }
}

void bubbleDown(MinHeap* heap, int nodeIndex){
    int left = leftIdx(heap,nodeIndex);
    int right = rightIdx(heap,nodeIndex);
    int m = nodeIndex;
    if (isValidIdx(heap, left) && priorityAt(heap, left) < priorityAt(heap, m)){
        m = left;
    }else if (isValidIdx(heap, right) && priorityAt(heap, right) < priorityAt(heap,m)){
        m = right;
    }
    if (m !=nodeIndex){
        swapNodes(heap,m,nodeIndex);
        bubbleDown(heap,m);
        bubbleDown(heap, nodeIndex);
    }
}

int getPriority(MinHeap* heap, int id){
    int index = indexOf(heap, id);
    return priorityAt(heap, index);
}


MinHeap* newHeap(int capacity) {
    MinHeap* pHeap = malloc(sizeof(MinHeap));
    pHeap->arr = (HeapNode*)malloc((capacity+1) * sizeof(HeapNode));
    pHeap->size = 0;
    pHeap->indexMap = malloc((capacity+1) * sizeof(int));
    pHeap->capacity = capacity;
    return pHeap;
}
void deleteHeap(MinHeap* heap) {
    if (heap == NULL) return;
    free(heap->arr);
    free(heap->indexMap);
    free(heap);
}

bool isUnique(MinHeap* heap, int id){
    for(int i = 0; i < heap->size + 1; i++){
        if(heap->arr[i].id == id){
            return false;
        }
    }
    return true;
}

/*********************************************************************
 * Required functions
 ********************************************************************/
HeapNode getMin(MinHeap* heap) {
    return heap->arr[ROOT_INDEX];
}

HeapNode extractMin(MinHeap* heap) {
    HeapNode min = getMin(heap);
    heap->arr[ROOT_INDEX] = heap->arr[heap->size];
    heap->indexMap[heap->arr[ROOT_INDEX].id] = ROOT_INDEX;
//    swapNodes(heap, ROOT_INDEX, heap->size);
    heap->size = heap->size - 1;
    bubbleDown(heap, ROOT_INDEX);
    int id = min.id;
    heap->indexMap[id] = 0;
    heap->arr[heap->size + 1].id = 0;
    heap->arr[heap->size + 1].priority = 0;
    return min;
}

void insert(MinHeap* heap, int priority, int id) {
    if (heap->size >= heap->capacity) {
        return;
    }
    HeapNode new;
    new.id = id;
    new.priority = priority;
    heap->arr[heap->size + 1] = new;
    heap->indexMap[id] = heap->size + 1;
    bubbleUp(heap,heap->size + 1);
    heap->size = heap->size + 1;
}

bool decreasePriority(MinHeap* heap, int id, int newPriority) {
    int nodeIndex = heap->indexMap[id];
    if (!isValidIdx(heap, nodeIndex)) {
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
