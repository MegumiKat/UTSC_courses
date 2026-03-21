//
// Created by Mark on 2024-02-04.
//
#include <stdio.h>
#include <stdlib.h>

#define PAGE_USER 2
#define PAGE_DIRTY 4
#define SET(var, flag) ((var) |= 1 <<(flag))

typedef struct node{
    int k;
    struct node* j;
}NODE;

NODE *new(int k){
    NODE * new = malloc(sizeof(NODE));
    new->k = k;
    new->j = NULL;
    return new;
}
int main() {
    NODE **list;
    list[1] = new(9);
    return 0;
}

Edge* getMSTprim(Graph* graph, int startVertex){
    bool* inMST = malloc(sizeof(bool) * graph->numVertices);
    for (int i = 0; i < graph->numVertices; i++) {
        inMST[i] = false;
    }
    Edge* mstEdges = malloc(sizeof(Edge) * (graph->numVertices - 1));
    inMST[startVertex] = true;
    for (int i = 1; i < graph->numVertices; i++) {
        int minWeight = INT_MAX;
        Edge* minEdge = NULL;
        for (int v = 0; v < graph->numVertices; v++){
            if(inMST[v]) {
                EdgeList* adjList = graph->vertices[v]->adjList;
                while(adjList != NULL) {
                    Edge* edge = adjList->edge;
                    int toVertex = edge->toVertex;
                    int weight = edge->weight;
                    if(!inMST[toVertex] && weight < minWeight) {
                        minWeight = weight;
                        minEdge = edge;
                    }
                    adjList = adjList->next;
                }
            }
        }
        mstEdges[i - 1] = *minEdge;
        inMST[minEdge->toVertex] = true;
    }
    free(inMST);
    for (int i = 0; i < graph->numVertices - 1; ++i) {
        int x;
        x = mstEdges[i].toVertex;
        mstEdges[i].toVertex = mstEdges[i].fromVertex;
        mstEdges[i].fromVertex = x;
    }
    return mstEdges;
}
Edge* getDistanceTreeDijkstra(Graph* graph, int startVertex){
    Records *records = malloc(sizeof(Records));
    MinHeap *PQ = records->heap;
    insert(PQ, 0, startVertex);
    for (int i = 0; i < graph->numVertices; ++i) {
        if (i != startVertex){
            insert(PQ, INT_MAX, i);
        }
    }
    while (!isEmpty(PQ)){
        HeapNode u = extractMin(PQ);
        addTreeEdge(records, records->numTreeEdges, u.id,records->predecessors[u.id], u.priority);
        EdgeList *l = graph->vertices[u.id]->adjList;
        while (l != NULL){
            Edge *e = l->edge;
            if (!records->finished[e->toVertex]){
                int d = u.priority + e->weight;
                if (d < getPriority(PQ, e->toVertex)){
                    decreasePriority(PQ, e->toVertex, d);
                    PQ->arr[PQ->indexMap[e->toVertex]].priority = d;
                    records->predecessors[e->toVertex] = u.id;
                }
            }
            l = l->next;
        }
        records->finished[u.id] = true;
    }
    free(records->predecessors);
    free(records->finished);
    deleteHeap(records->heap);
    return records->tree;
}
EdgeList** shortestPaths = malloc(sizeof(EdgeList*) * numVertices);
for (int i = 0; i < numVertices; ++i) {
int currentVertex = i;
EdgeList* shortestPath = NULL;
while (currentVertex != startVertex) {
Edge* currentEdge = NULL;
for (int j = 0; j < numVertices - 1; ++j) {
if (distTree[j].toVertex == currentVertex) {
currentEdge = &distTree[j];
break;
}
}
shortestPath = newEdgeList(currentEdge, shortestPath);
currentVertex = currentEdge->fromVertex;
}
shortestPaths[i] = shortestPath;
}
return shortestPaths;

if (startVertex < 0 || startVertex >= numVertices) return NULL;
EdgeList **path = malloc(numVertices * sizeof(EdgeList*));
path[startVertex] = NULL;
Edge *copy = distTree;
for(int i = 0; i < numVertices; i++){
if (distTree[i].toVertex != startVertex){
for (int j = 0; j < numVertices; ++j) {
if (copy[j].fromVertex == distTree[i].toVertex){
int d = distTree[i].weight - copy[j].weight;
distTree[i].weight = d;
}
}
}
}
for (int i = 0; i < numVertices; ++i) {
for (int j = 0; j < numVertices; ++j) {
if (i != startVertex && distTree[j].fromVertex == i){
path[i] = newEdgeList(&distTree[j], NULL);
EdgeList *p = path[i];
while(p->edge->toVertex != startVertex) {
for (int n = 0; n < numVertices; ++n) {
if (n != startVertex && p->edge->toVertex == distTree[n].fromVertex){
p->next = newEdgeList(&distTree[n], NULL);
}
}
p = p->next;
}
}
}
}
return path;