#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
    if(fork()==0)
    {if(fork()==0){fork();}else{}}
    else
    {sleep(1);ps();}
    exit(0);
}