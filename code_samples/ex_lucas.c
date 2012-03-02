#include <pthread.h>

#define N 3

int s = 0;
int a[2];

void *my_thread(void *arg) {
  s++;
  a[s]=s;
  s--;
}

int main(){
  pthread_t id[N];
  pthread_create(&id[0], NULL, my_thread, NULL);
  pthread_create(&id[1], NULL, my_thread, NULL);
  pthread_create(&id[2], NULL, my_thread, NULL);
}
