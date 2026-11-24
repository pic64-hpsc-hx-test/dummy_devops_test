/* (c) 2026 Microchip Technology Inc. SPDX-License-Identifier: MIT */
#include <stdio.h>
#include "calc.h"

static int failures;

#define EXPECT(op, a, b, want_status, want)                                              \
    do {                                                                                 \
        long r = 0;                                                                      \
        calc_status_t s = calc_eval(op, a, b, &r);                                            \
        if (s != (want_status) || (s == CALC_OK && r != (want))) {                       \
            printf("FAIL %s(%ld, %ld): status %d result %ld\n", op, (long)(a), (long)(b), s, r); \
            failures++;                                                                  \
        } else {                                                                         \
            printf("ok   %s(%ld, %ld)\n", op, (long)(a), (long)(b));                     \
        }                                                                                \
    } while (0)

int main(void)
{
    EXPECT("add", 2, 3, CALC_OK, 5);
    EXPECT("sub", 2, 3, CALC_OK, -1);
    EXPECT("mul", -4, 3, CALC_OK, -12);
    EXPECT("div", 7, 2, CALC_OK, 4);
    EXPECT("div", 1, 0, CALC_DIV_ZERO, 0);
    EXPECT("mod", 7, 3, CALC_OK, 1);
    EXPECT("mod", 7, 0, CALC_DIV_ZERO, 0);
    EXPECT("pow", 1, 1, CALC_BAD_OP, 0);
    printf("%d failure(s)\n", failures);
    return failures ? 1 : 0;
}
