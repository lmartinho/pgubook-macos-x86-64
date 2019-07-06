#include <unistd.h>

void call_sbrk(void) {
    sbrk(0);
}

int main(void) {
    call_sbrk();
}
