
#include <stdint.h>
 
static void bubble_sort(int32_t *a, int n) {
    for (int i = 0; i < n - 1; i++)
        for (int j = 0; j < n - 1 - i; j++)
            if (a[j] > a[j + 1]) {
                int32_t t = a[j];
                a[j] = a[j + 1];
                a[j + 1] = t;
            }
}
 
int main(void) {
    int32_t arr[8] = {5, -3, 42, 0, 17, -8, 9, 1};  /// -8 -3 0 1 5 17 42
    bubble_sort(arr, 8);
    
}
