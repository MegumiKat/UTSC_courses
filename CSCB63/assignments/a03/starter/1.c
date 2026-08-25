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
  MinHeap *heap = newHeap(graph->numVertices);
  Vertex **vertex = graph->vertices;
  for (int i = 0; i < graph->numVertices; i++){
    if(vertex[i]->id == startVertex){
      // EdgeList *edgelist = vertex[i]->adjList;
      // EdgeList *p = edgelist;
      // while (p != NULL)
      // {
      //   insert(heap,p->edge->weight,p->edge->toVertex);
      //   p = p->next;
      // }
      insert(heap,0,startVertex);
    }else{
      insert(heap,INT_MAX,vertex[i]->id);
    }
  }
  return heap;
}

/* Creates, populates, and returns all records needed to run Prim's and
 * Dijkstra's algorithms on Graph 'graph' starting from vertex with ID
 * 'startVertex'.
 * Precondition: 'startVertex' is valid in 'graph'
 */

Records* initRecords(Graph* graph, int startVertex){
  Records *record = (Records *)malloc(sizeof(Records));
  record->numTreeEdges = 0;
  record->heap = initHeap(graph,startVertex);
  record->numVertices = graph->numVertices;
  record->finished = (bool *)malloc(sizeof(bool)*(record->numVertices));
  record->predecessors = (int *)malloc(sizeof(int)*(record->numVertices));
  for(int i = 0; i < record->numVertices; i++){
    record->finished[i] = false;
    record->predecessors[i] = startVertex;
  }
  record->tree = (Edge *)malloc(sizeof(record->numVertices) * sizeof(Edge));
  for(int id = 0; id < record->numVertices; id++){
    record->tree[id].fromVertex = id;
    record->tree[id].toVertex = startVertex;
    if(id != startVertex){
      record->tree[id].weight = INT_MAX;
    }else{
      record->tree[id].weight = 0;
    }
  }
  return record;
}

void deleteRecords(Records *record){       // free memory of record
  free(record->finished);
  free(record->predecessors);
  //free(record->tree);
  deleteHeap(record->heap);
  free(record);
}

/* Returns true iff 'heap' is NULL or is empty. */
bool isEmpty(MinHeap* heap){
  if (heap == NULL || heap->size == 0) return true;
  return false;
}


/* Add a new edge to records at index ind. */
void addTreeEdge(Records* records, int ind, int fromVertex, int toVertex,int weight){
  //Edge *edge = newEdge(fromVertex,toVertex,weight);
  //records->tree[ind] = *edge;
  records->tree[ind].fromVertex = fromVertex;
  records->tree[ind].toVertex = toVertex;
  records->tree[ind].weight = weight;
  records->numTreeEdges ++;
}

EdgeList *insertEdge(EdgeList* head, Edge *edge){
  EdgeList *endEdge = head;
  if (head == NULL){
    head = newEdgeList(edge,NULL);
  }
  while (endEdge->next != NULL)
  {
    endEdge = endEdge->next;
  }
  endEdge->next = newEdgeList(edge,NULL);
  return head;
}

Edge* findPosition(Edge* distTree, int vertex){
  Edge *vertexTree = distTree;
  // find the edge st edge.toVertex == vertex
  while(vertexTree->fromVertex != vertex){
    vertexTree ++;          // move to next vertex in that array
  }
  return vertexTree;
}

/* Creates and returns a path from 'vertex' to 'startVertex' from edges
 * in the distance tree 'distTree'.
 */
EdgeList* makePath(Edge* distTree, int vertex, int startVertex){
  EdgeList *path = NULL;
  EdgeList *pathfrienf = NULL;
  Edge *vertexTree = findPosition(distTree,vertex);
  while (vertex != startVertex)
  {
    vertex = vertexTree->toVertex;  // move to next vertex
    path = insertEdge(path,vertexTree); // insert path
    vertexTree = findPosition(distTree,vertex); // next edge
  }
  return path;
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
  int numVertex = graph->numVertices;
  if(startVertex > numVertex || numVertex < 1) return NULL; // not a valid startVertex || graph is empty
  Edge *edge = NULL; // (numVertex - 1) == minimun edge
  Vertex **vertex = graph->vertices;
  Records *record = initRecords(graph,startVertex);
  MinHeap *heap = record->heap;
  while (!isEmpty(heap)){
    HeapNode minNode = extractMin(heap);
    if(minNode.id != startVertex){
    addTreeEdge(record,record->numTreeEdges,minNode.id,record->predecessors[minNode.id],minNode.priority);
    }
    EdgeList *adjlist = vertex[minNode.id]->adjList;
    while(adjlist != NULL){
      Edge *current = adjlist->edge;
      if(current->weight < getPriority(heap,current->toVertex) && !record->finished[current->toVertex]){
        decreasePriority(heap, current->toVertex, current->weight);
        //int indexofToVertex = heap->indexMap[current->toVertex];
        //heap->arr[indexofToVertex].priority = current->weight;
        record->predecessors[current->toVertex] = minNode.id;
      }
      adjlist = adjlist->next;
    }
    record->finished[minNode.id] = true;
  }
  edge = record->tree;
  deleteRecords(record);
  return edge;
}

/* Runs Dijkstra's algorithm on Graph 'graph' starting from vertex with ID
 * 'startVertex', and return the resulting distance tree: an array of edges.
 * Returns NULL if 'startVertex' is not valid in 'graph'.
 * Precondition: 'graph' is connected.
 */
Edge* getDistanceTreeDijkstra(Graph* graph, int startVertex){
  int numVertex = graph->numVertices;
  if(startVertex > numVertex || numVertex < 1) return NULL; // not a valid startVertex || graph is empty
  Edge *edge = NULL; // (numVertex - 1) == minimun edge
  Records *record = initRecords(graph,startVertex);
  Vertex **vertex = graph->vertices;
  MinHeap *heap = record->heap;
  while (!isEmpty(heap))
  {
//    HeapNode minNode = extractMin(heap);
    HeapNode minNode = heap->arr[1];
//    addTreeEdge(record,record->numTreeEdges,minNode.id,record->predecessors[minNode.id],minNode.priority);
    EdgeList *adjlist = vertex[minNode.id]->adjList;
    while (adjlist != NULL)
    {
      Edge *current = adjlist->edge;
      if(!record->finished[current->toVertex]){
        int new_weight = current->weight + minNode.priority;
        if(new_weight < getPriority(heap,current->toVertex)){
          decreasePriority(heap, current->toVertex, new_weight);
          //record->tree[current->toVertex].weight = new_weight;
          record->predecessors[current->toVertex] = minNode.id;
        }
      }
      adjlist = adjlist->next;
    }
    record->finished[minNode.id] = true;
  }
  edge = record->tree;
  deleteRecords(record);
  return edge;
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
  if(startVertex > numVertices || numVertices < 1) return NULL; // not a valid startVertex || graph is empty
  EdgeList **shortestPath = (EdgeList **)malloc(sizeof(EdgeList *)*numVertices);
  for(int j = 0; j < numVertices; j++){
    shortestPath[j] = makePath(distTree,j,startVertex);
  }
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
