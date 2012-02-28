#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <time.h>

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

int nondet_uint();

int nondet_uint(){
	
	srand(time(NULL));
 	int result = rand() % 10;
	return result;
		
}


void d_div(){
	
	unsigned int a, b, c;
	
    a=nondet_uint();
	b=nondet_uint();
	int i;

	if(a>0 || b>0){
		for(i=0; i < 12; i++){
		   if (i == 11){			  
			  c=1/(a+b);
	       }
	    }
	}
	
		
}

main()
{
	calc(12,7);
	d_div();
}
