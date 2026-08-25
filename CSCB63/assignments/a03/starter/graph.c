/*
 * Our graph implementation.
 *
 * Author: A. Tafliovich.
 */

#include "graph.h"

/*********************************************************************
 ** Helper function provided in the starter code
 *********************************************************************/

void printEdge(Edge* edge) {
  if (edge == NULL)
    printf("NULL");
  else
    printf("(%d -- %d, %d)", edge->fromVertex, edge->toVertex, edge->weight);
}

void printEdgeList(EdgeList* head) {
  while (head != NULL) {
    printEdge(head->edge);
    printf(" --> ");
    head = head->next;
  }
  printf("NULL");
}

void printVertex(Vertex* vertex) {
  if (vertex == NULL) {
    printf("NULL");
  } else {
    printf("%d: ", vertex->id);
    printEdgeList(vertex->adjList);
  }
}

void printGraph(Graph* graph) {
  if (graph == NULL) {
    printf("NULL");
    return;
  }
  printf("Number of vertices: %d. Number of edges: %d.\n\n", graph->numVertices,
         graph->numEdges);

  for (int i = 0; i < graph->numVertices; i++) {
    printVertex(graph->vertices[i]);
    printf("\n");
  }
  printf("\n");
}

/*********************************************************************
 ** Required functions
 *********************************************************************/
Edge* newEdge(int fromVertex, int toVertex, int weight){
    Edge *new = malloc(sizeof(Edge));
    new->fromVertex = fromVertex;
    new->toVertex = toVertex;
    new->weight = weight;
    return new;
}

EdgeList* newEdgeList(Edge* edge, EdgeList* next){
    EdgeList *new = malloc(sizeof(EdgeList));
    new->edge = edge;
    new->next = next;
    return new;
}

Vertex* newVertex(int id, void* value, EdgeList* adjList){
    Vertex *new = malloc(sizeof(Vertex));
    new->id = id;
    new->value = value;
    new->adjList = adjList;
    return new;
}

Graph* newGraph(int numVertices){
    Graph *new = malloc(sizeof(Graph));
    new->numVertices = numVertices;
    new->numEdges = 0;
    new->vertices = malloc(numVertices * sizeof(Vertex*));
    return new;
}

void deleteEdgeList(EdgeList* head){
        while (head != NULL) {
            EdgeList* temp = head;
            head = head->next;
            free(temp->edge);
            free(temp);
        }
}

void deleteVertex(Vertex* vertex){
    deleteEdgeList(vertex->adjList);
    free(vertex->value);
    free(vertex);
}

void deleteGraph(Graph* graph){
    for(int i = 0; i < graph->numVertices; i++){
        deleteVertex(graph->vertices[i]);
    }
    free(graph->vertices);
    free(graph);
}