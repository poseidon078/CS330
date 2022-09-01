#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
    int a=5;
    int *p=&a;
    if(fork()==0)
    printf("%p %p\n", p, (void*)getpa(p));
    else{
        wait(p);
        printf("%p %p\n", p, (void*)getpa(p));
    }
    exit(0);
}