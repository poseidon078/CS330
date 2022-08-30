#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
    int m=atoi(argv[1]);
    int n=atoi(argv[2]);
    int x;
    if(m<1){
        printf("m should be positive\n");
        exit(1);
    }
    if(n<0 || n>1){
        printf("n should be 0 or 1\n");
        exit(2);
    }
    if(fork()==0){
        if(n==0){
            sleep(m);
            printf("%d: Child.\n", getpid());
        }
        else{
            printf("%d: Child.\n", getpid());
        }
    }
    else{
        if(n==0){
            printf("%d: Parent.\n", getpid());
            int *p=&x;
            wait(p);
        }
        else{
            sleep(m);
            printf("%d: Parent.\n", getpid());
        }
    }
  exit(0);
}
