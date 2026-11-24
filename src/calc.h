/* (c) 2026 Microchip Technology Inc. SPDX-License-Identifier: MIT */
#ifndef DUMMY_CALC_H
#define DUMMY_CALC_H

typedef enum { CALC_OK = 0, CALC_BAD_OP, CALC_DIV_ZERO } calc_status_t;

/* Applies op ("add", "sub", "mul", "div", "mod") to a and b. */
calc_status_t calc_eval(const char *op, long a, long b, long *result);

#endif
