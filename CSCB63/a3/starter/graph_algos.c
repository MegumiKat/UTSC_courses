/*
 * Graph algorithms.
 *
 * Author (of starter code): A. Tafliovich.
 */

#include <limits.h>

#include "graph.h"
#include "minheap.h"

#define NOTHING -1
#define DEBUG 0

typedef struct records {
    int numVertices;    // total number of vertices in the graph
    // vertex IDs are 0, 1, ..., numVertices-1
    MinHeap* heap;      // priority queue
    bool* finished;     // finished[id] is true iff vertex id is finished
    //   i.e. no longer in the PQ
    int* predecessors;  // predecessors[id] is the predecessor of vertex id
    Edge* tree;         // keeps edges for the resulting tree
    int numTreeEdges;   // current number of edges in mst
} Records;

/*************************************************************************
 ** Suggested helper functions -- part of starter code
 *************************************************************************/
/* Creates, populates, and returns a MinHeap to be used by Prim's and
 * Dijkstra's algorithms on Graph 'graph' starting from vertex with ID
 * 'startVertex'.
 * Precondition: 'startVertex' is valid in 'graph'
 */
MinHeap* initHeap(Graph* graph, int startVertex){
    MinHeap *new = newHeap(graph->numVertices);
    insert(new, 0, startVertex);
    return new;
}

/* Creates, populates, and returns all records needed to run Prim's and
 * Dijkstra's algorithms on Graph 'graph' starting from vertex with ID
 * 'startVertex'.
 * Precondition: 'startVertex' is valid in 'graph'
 */
Records* initRecords(Graph* graph, int startVertex) {
    Records *new = malloc(sizeof(Records));
    new->numVertices = graph->numVertices;
    new->heap = initHeap(graph, startVertex);
    new->finished = malloc(sizeof(bool) * graph->numVertices);
    for (int i = 0; i < graph->numVertices; i++) {
        new->finished[i] = false;
    }
    new->predecessors = malloc(sizeof(int) * graph->numVertices);
    for (int i = 0; i < graph->numVertices; i++) {
        new->predecessors[i] = startVertex;
    }
    new->tree = malloc(sizeof(Edge) * graph->numVertices);
    new->numTreeEdges = 0;
    return new;
}
/* Returns true iff 'heap' is NULL or is empty. */
bool isEmpty(MinHeap* heap){
    return (heap == NULL || heap->size == 0);
}


/* Add a new edge to records at index ind. */
void addTreeEdge(Records* records, int ind, int fromVertex, int toVertex, int weight){
    if(records == NULL){
        return;
    }
    if(ind < 0 || ind >= records->numVertices){
        return;
    }
    records->tree[ind].fromVertex = fromVertex;
    records->tree[ind].toVertex = toVertex;
    records->tree[ind].weight = weight;
    records->numTreeEdges++;
}

/* Creates and returns a path from 'vertex' to 'startVertex' from edges
 * in the distance tree 'distTree'.
 */
EdgeList* makePath(Edge* distTree, int vertex, int startVertex){
    EdgeList* path = NULL;
    if (vertex != startVertex) {
        Edge* edge = newEdge(distTree[vertex].fromVertex, distTree[vertex].toVertex, distTree[vertex].weight);
        EdgeList* newNode = newEdgeList(edge, makePath(distTree, edge->toVertex, startVertex));
        path = newNode;
    }
    return path;
}
void deleteRecord(Records* records){
    free(records->finished);
    deleteHeap(records->heap);
    free(records->predecessors);
    free(records);
}
/*************************************************************************
 ** Required functions
 *************************************************************************/
/* Runs Prim's algorithm on Graph 'graph' starting from vertex with ID
 * 'startVertex', and return the resulting MST: an array of Edges.
 * Returns NULL is 'startVertex' is not valid in 'graph'.
 * Precondition: 'graph' is connected.
 */
Edge* getMSTprim(Graph* graph, int startVertex){
    if (startVertex < 0 || startVertex >= graph->numVertices) return NULL;
    Records* records = initRecords(graph, startVertex);
    MinHeap* PQ = records->heap;
    for(int i = 0; i < records->numVertices; i++){
        if(i != startVertex){
            insert(PQ, INT_MAX, i);
        }
    }
//    printf("%d\n", PQ->arr[0].priority);
    while(!isEmpty(PQ)){
//        printf("%d\n", getMin(PQ).id);
        HeapNode u = extractMin(PQ);
        if (u.id != startVertex){
            addTreeEdge(records, records->numTreeEdges, u.id,records->predecessors[u.id], u.priority);
        }
        EdgeList *l = graph->vertices[u.id]->adjList;
        while(l != NULL){
            Edge* e = l->edge;
            if(!records->finished[e->toVertex] && e->weight < getPriority(PQ, e->toVertex)){
                decreasePriority(PQ, e->toVertex, e->weight);
                records->predecessors[e->toVertex] = u.id;
            }
            l = l->next;
        }
        records->finished[u.id] = true;
    }
    Edge *mst = records->tree;
    deleteRecord(records);
    return mst;
}

/* Runs Dijkstra's algorithm on Graph 'graph' starting from vertex with ID
 * 'startVertex', and return the resulting distance tree: an array of edges.
 * Returns NULL if 'startVertex' is not valid in 'graph'.
 * Precondition: 'graph' is connected.
 */
Edge* getDistanceTreeDijkstra(Graph* graph, int startVertex){
    if (startVertex < 0 || startVertex >= graph->numVertices) return NULL;
    Records *records = initRecords(graph, startVertex);
    MinHeap *PQ = records->heap;
    for (int i = 0; i < graph->numVertices; i++) {
        if (i != startVertex) {
            insert(PQ, INT_MAX, i);
        }
    }
    while (!isEmpty(PQ)){
        HeapNode u = extractMin(PQ);
        addTreeEdge(records, u.id, u.id,records->predecessors[u.id], u.priority);
        EdgeList *l = graph->vertices[u.id]->adjList;
        while (l != NULL){
            Edge *e = l->edge;
            if (!records->finished[e->toVertex]) {
                int d = u.priority + e->weight;
                if (d < getPriority(PQ, e->toVertex)) {
                    decreasePriority(PQ, e->toVertex, d);
                    records->predecessors[e->toVertex] = u.id;
                }
            }
            l = l->next;
        }
        records->finished[u.id] = true;
    }
    Edge *dst = records->tree;
    deleteRecord(records);
    return dst;
}

/* Creates and returns an array 'paths' of shortest paths from every vertex
 * in the graph to vertex 'startVertex', based on the information in the
 * distance tree 'distTree' produced by Dijkstra's algorithm on a graph with
 * 'numVertices' vertices and with the start vertex 'startVertex'.  paths[id]
 * is the list of edges of the form
 *   [(id -- id_1, w_0), (id_1 -- id_2, w_1), ..., (id_n -- start, w_n)]
 *   where w_0 + w_1 + ... + w_n = distance(id)
 * Returns NULL if 'startVertex' is not valid in 'distTree'.
 */
EdgeList** getShortestPaths(Edge* distTree, int numVertices, int startVertex){
    if (startVertex < 0 || startVertex >= numVertices) return NULL;
    Edge copy[numVertices];
    for (int i = 0; i < numVertices; ++i) {
        copy[i] = distTree[i];
    }
    for (int i = 0; i < numVertices; ++i) {
        for (int j = 0; j < numVertices; ++j) {
            if (distTree[i].toVertex == distTree[j].fromVertex){
                int d = distTree[i].weight - copy[j].weight;
                distTree[i].weight = d;
            }
        }
    }
    EdgeList **path = malloc(numVertices * sizeof(EdgeList*));
    for (int i = 0; i < numVertices; ++i) {
        path[i] = makePath(distTree, i, startVertex);
    }
    return path;
}

/*************************************************************************
 ** Provided helper functions -- part of starter code to help you debug!
 *************************************************************************/
void printRecords(Records* records) {
    if (records == NULL) return;

    int numVertices = records->numVertices;
    printf("Reporting on algorithm's records on %d vertices...\n", numVertices);

    printf("The PQ is:\n");
    printHeap(records->heap);

    printf("The finished array is:\n");
    for (int i = 0; i < numVertices; i++)
        printf("\t%d: %d\n", i, records->finished[i]);

    printf("The predecessors array is:\n");
    for (int i = 0; i < numVertices; i++)
        printf("\t%d: %d\n", i, records->predecessors[i]);

    printf("The TREE edges are:\n");
    for (int i = 0; i < records->numTreeEdges; i++) printEdge(&records->tree[i]);

    printf("... done.\n");
}
