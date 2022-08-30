#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void pipelining(int n, int *pipefd){
    if(n==0){
        exit(0);
    }
    if(fork()==0){
        int x;
        if (read(pipefd[0], &x, 4) < 0) {
			printf("Error: cannot read. Aborting...\n");
			exit(0);
		}
        else{
            int pipefd1[2];
            if (pipe(pipefd1) < 0) {
                printf("Error: cannot create pipe. Aborting...\n");
                exit(0);
            }
            x=x+getpid();
            printf("%d: %d\n", getpid(), x);
            if (write(pipefd1[1], &x, 4) < 0) {
                printf("Error: cannot write. Aborting...\n");
                exit(0);
            }
            else{
                close(pipefd[0]);
                close(pipefd1[1]);
                pipelining(n-1, pipefd1);

            }
        }
    
    }
    else{
        int a=5;
        int *p=&a;
        wait(p);
    }
}

int
main(int argc, char **argv)
{
    int n=atoi(argv[1]);
    int x=atoi(argv[2]);
    int pipefd[2];
    if(n<1){
        printf("m should be positive\n");
        exit(1);
    }
    if (pipe(pipefd) < 0) {
		printf("Error: cannot create pipe. Aborting...\n");
		exit(0);
	}
    // printf("Error: cannot create pipe. Aborting...\n");
    // exit(0)

    if(1){
            x=x+getpid();
            printf("%d: %d\n", getpid(), x);
            if (write(pipefd[1], &x, 4) < 0) {
                printf("Error: cannot write. Aborting...\n");
                exit(0);
            }
            else{
                close(pipefd[1]);
            }
            pipelining(n-1, pipefd);
    }
    exit(0);
}
