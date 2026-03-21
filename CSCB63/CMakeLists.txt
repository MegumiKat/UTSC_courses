cmake_minimum_required(VERSION 3.27)
project(CSCB63 C)

set(CMAKE_C_STANDARD 11)

add_executable(CSCB63 main.c )

add_executable(CSCB63_1
        a1/starter/BST.c)

add_executable(CSCB63_2 草稿.c )

add_executable(A2 a2/starter/minheap.c a2/starter/minheap_tester.c a2/starter/minheap.h)

add_executable(A3 a3/starter/graph_algos.c
        a3/starter/graph.c
        a3/starter/graph_tester.c
        a3/starter/minheap.c a3/starter/sample_input.txt)
