#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void pipelining(int i, int *primes, int *pipefd){
    if(fork()==0){
        int n;
        if (read(pipefd[0], &n, 4) < 0) {
			printf("Error: cannot read. Aborting...\n");
			exit(0);
		}
        else{
            
            int pipefd1[2];
            if (pipe(pipefd1) < 0) {
                printf("Error: cannot create pipe. Aborting...\n");
                exit(0);
            }            
            
            // while(n%primes[i]!=0)
            // i++;
            int x=primes[i];
            int flag=0;
            while(n%x==0){
                n=n/x;
                printf("%d, ", x);
                flag=1;
            }
            if(flag)
            printf("[%d]\n", getpid());
            if(n==1){
                exit(0);
            }
            if (write(pipefd1[1], &n, 4) < 0) {
                printf("Error: cannot write. Aborting...\n");
                exit(0);
            }
            else{
                close(pipefd[0]);
                close(pipefd1[1]);
                pipelining(i+1,primes,pipefd1);

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
    int primes[]={2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97};
    int x=primes[0];
    int pipefd[2];
    if(n<2 || n>100){
        printf("n should be positive\n");
        exit(1);
    }
    if (pipe(pipefd) < 0) {
		printf("Error: cannot create pipe. Aborting...\n");
		exit(0);
	}
    // printf("Error: cannot create pipe. Aborting...\n");
    // exit(0)

    if(1){
            int i=0;
            // while(n%primes[i]!=0)
            // i++;
            int flag=0;
            x=primes[i];
            while(n%x==0){
                n=n/x;
                printf("%d, ", x);
                flag=1;
            }
            if(flag)
            printf("[%d]\n", getpid());
            if(n==1){
                exit(0);
            }
            if (write(pipefd[1], &n, 4) < 0) {
                printf("Error: cannot write. Aborting...\n");
                exit(0);
            }
            else{
                close(pipefd[1]);
            }
            pipelining(i+1,primes,pipefd);
    }
    exit(0);
}
