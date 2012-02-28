#include <stdio.h>
#include <ctype.h>

calc(int a, int b){
	int z[4]={2,6,1,9};
	int i;
	char *p;
		
	for(i=0;b<a;i++){
		if(i == b){
			z[i]=b;
			*(p+i)='x';
		}
	}
}

main(argc,argv)
int argc;
char *argv[3];
{
	calc(12,7);
}
