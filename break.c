#include <stdio.h>
#include <unistd.h>

int main(void) {
    void *res = (void *) 10;
    res = sbrk(1);
    printf("address: %#x\n", res);
    res = sbrk(1);
    printf("address: %#x\n", res);
    return 0;
}