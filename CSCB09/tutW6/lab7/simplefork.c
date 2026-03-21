#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main() {
	int ret;

	printf("A\n");
	ret = fork();

	printf("B\n");
	if(ret < 0) {
		perror("fork");
		exit(1);

	} else if(ret == 0) {
		printf("C\n");

	} else {
		printf("D\n");
	}

	printf("E\n");
	return 0;
}


print:
    A-----------------
    B                   | B
    D                   | C
    E                   | E

    Q1: B E
    Q2:
        1. A B D E B C E
        2. A B C E B D E
        3. A B B C D E E