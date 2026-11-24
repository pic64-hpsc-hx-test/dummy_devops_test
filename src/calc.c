/* (c) 2026 Microchip Technology Inc. SPDX-License-Identifier: MIT */
#include <string.h>
#include "calc.h"

calc_status_t calc_eval(const char *op, long a, long b, long *result)
{
    if (strcmp(op, "add") == 0) {
        *result = a + b;
    } else if (strcmp(op, "sub") == 0) {
        *result = a - b;
    } else if (strcmp(op, "mul") == 0) {
        *result = a * b;
    } else if (strcmp(op, "div") == 0) {
        if (b == 0) {
            return CALC_DIV_ZERO;
        }
        /* round to nearest, halves away from zero (was: truncate) */
        long q = a / b, r = a % b;
        if (2 * (r < 0 ? -r : r) >= (b < 0 ? -b : b)) {
            q += ((a < 0) == (b < 0)) ? 1 : -1;
        }
        *result = q;
    } else if (strcmp(op, "mod") == 0) {
        if (b == 0) {
            return CALC_DIV_ZERO;
        }
        /* always non-negative, like Python (was: the sign of a) */
        long m = a % b;
        *result = (m < 0) ? m + (b < 0 ? -b : b) : m;
    } else {
        return CALC_BAD_OP;
    }
    return CALC_OK;
}
