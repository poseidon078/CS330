#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// uncomment yield() in child then in parent then both and see four different results
int
main(int argc, char **argv)
{
    if(fork()==0){
        // yield();
        printf("%d\n", getpid());
    }
    else{
        // yield();
        printf("%d\n", getpid());
    }
    
    exit(0);
}