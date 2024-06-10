#include <stdio.h>
#include <stdlib.h>

int main(void)
{
#if _WIN32
  printf("aligned-alloc not supported in MinGW\n");
#else
  int *p2 = (int*)aligned_alloc(1024, 1024*sizeof *p2);
  printf("1024-byte aligned addr: %p\n", (void*)p2);
  free(p2);
#endif
}
