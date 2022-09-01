#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void pipelining(int n){
    if(n==0){
        exit(0);
    }
    if(fork()==0){
        printf("hello %d\n", n);
        pipelining(n-1);
    }    
    else{
        exit(0);
    }
}

int
main(int argc, char **argv)
{
    pipelining(atoi(argv[1]));
    exit(0);
}