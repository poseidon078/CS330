#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
int pipefd[2];
int y;
int *p=&y;
int n;

void pipelining(){
    if(n==0){
        exit(0);
    }
    if(fork()==0){
        if (read(pipefd[0], &y, 4) < 0) {
			printf("Error: cannot read. Aborting...\n");
			exit(0);
		}
        else{
            y=y+getpid();
            printf("%d: %d\n", getpid(), y);
            if (write(pipefd[1], &y, 4) < 0) {
                printf("Error: cannot write. Aborting...\n");
                exit(0);
            }
            else{
                n=n-1;
                pipelining();
            }
        }
    
    }
    else{
        close(pipefd[0]);
        close(pipefd[1]);
        wait(p);
    }
}

int
main(int argc, char **argv)
{
    n=atoi(argv[1]);
    int x=atoi(argv[2]);
    
    if(n<1){
        printf("m should be positive\n");
        exit(1);
    }
    if (pipe(pipefd) < 0) {
		printf("Error: cannot create pipe. Aborting...\n");
		exit(0);
	}
    

    if(1){
            x=x+getpid();
            printf("%d: %d\n", getpid(), x);
            if (write(pipefd[1], &x, 4) < 0) {
                printf("Error: cannot write. Aborting...\n");
                exit(0);
            }
            else{
                n=n-1;
                pipelining();
            }           
    }
    exit(0);
}
