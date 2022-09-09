#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
    int d,e,f;
    int r;
    printf("Hello I will wait for my child to complete pid=%d ppid=%d\n", getpid(), getppid());
    if((d=fork())==0){
        printf("Hello I will wait for my child to complete pid=%d ppid=%d\n", getpid(), getppid());
        if((d=fork())==0){
            sleep(5);
            printf("Hello I will wait for my child to complete pid=%d ppid=%d\n", getpid(), getppid());
            if((d=fork())==0){
                printf("Hello Im pid=%d ppid=%d\n", getpid(), getppid());
            }
            else if((f=fork())==0){
                sleep(5);
                printf("Hello Im pid=%d ppid=%d\n", getpid(), getppid());
            }
            else{
                // printf("Hello Im waiting for my child to complete child pid=%d pid=%d ppid=%d\n", d, getpid(), getppid());
                r=waitpid(-1,(int*)0);
                printf("Hello Im exiting now after having waited for my child to complete child pid=%d pid=%d ppid=%d\n", r, getpid(), getppid());
                r=waitpid(-1,(int*)0);
                printf("Hello Im exiting now after having waited for my child to complete child pid=%d pid=%d ppid=%d\n", r, getpid(), getppid());
            }
        }
        else if((e=fork())==0){
            printf("Hello I will wait for my child to complete pid=%d ppid=%d\n", getpid(), getppid());
            // if((d=fork())==0){
            //     printf("Hello Im pid=%d ppid=%d\n", getpid(), getppid());
            // }
            // else if((f=fork())==0){
            //     sleep(5);
            //     printf("Hello Im pid=%d ppid=%d\n", getpid(), getppid());
            // }
            // else{
            //     // printf("Hello Im waiting for my child to complete child pid=%d pid=%d ppid=%d\n", d, getpid(), getppid());
            //     r=waitpid(d,(int*)0);
            //     r=waitpid(-1,(int*)0);
            //     printf("Hello Im exiting now after having waited for my child to complete child pid=%d pid=%d ppid=%d\n", r, getpid(), getppid());
            // }
        }
        else{
            // printf("Hello Im waiting for my child to complete child pid=%d pid=%d ppid=%d\n", d, getpid(), getppid());
            r=waitpid(-1,(int*)0);
            printf("Hello Im exiting now after having waited for my child to complete child pid=%d pid=%d ppid=%d\n", r, getpid(), getppid());
            r=waitpid(-1,(int*)0);
            printf("Hello Im exiting now after having waited for my child to complete child pid=%d pid=%d ppid=%d\n", r, getpid(), getppid());
        }
    }
    else{
        // printf("Hello Im waiting for my child to complete child pid=%d pid=%d ppid=%d\n", d, getpid(), getppid());
        r=waitpid(-1,(int*)0);
        printf("Hello Im exiting now after having waited for my child to complete child pid=%d pid=%d ppid=%d\n", r, getpid(), getppid());
    }
    exit(0);
}