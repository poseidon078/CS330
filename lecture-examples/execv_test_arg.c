#include <stdio.h>
#include <stdlib.h>

int main (void)
{
        char *argv[5];
        argv[0] = "caesar-cipher";
        argv[1] = "ZHOFRPH";
        argv[2] = "WR";
        argv[3] = "FV663";
 	argv[4] = "\0";
	execv("caesar-cipher",argv);
	printf("Returned from execv call.\n");
	return 0;
}