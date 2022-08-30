#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

int *p;

void work (void)
{
   while(1) {
      sleep(1);
      *p = *p + 1;
      printf("(%d) value at p: %d\n", getpid(), *p);
   }
}

int main (int argc, char *argv[])
{
   p = (int*)malloc(sizeof(int));
   assert(p != NULL);
   printf("(%d) address pointed to by p: %p\n", getpid(), p);
   *p = 0;
   work();

   return 0;
}