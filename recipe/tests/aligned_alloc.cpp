#include <cstdio>
#include <cstdlib>
#include <cstdint>

int main(void)
{
#if _WIN32
  printf("aligned-alloc not supported in MinGW\n");
#else
  /// int *p2 = (int*)memalign(1024, 1024 * sizeof *p2);
  int *p2;
  int err = posix_memalign((void**)&p2, 1024, sizeof *p2);
  printf("1024-byte aligned addr: %p\n", (void*)p2);
  free(p2);
  p2 = (int*)std::aligned_alloc(1024, 1);
  printf("1024-byte aligned addr: %p\n", (void*)p2);
  std::free(p2);
  p2 = (int*)aligned_alloc(1024, 1024);
  printf("1024-byte aligned addr: %p\n", (void*)p2);
#endif
}
