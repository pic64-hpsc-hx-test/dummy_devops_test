/* (c) 2026 Microchip Technology Inc. SPDX-License-Identifier: MIT */
#include <stdio.h>
#include <stdlib.h>
#include "calc.h"
#include "log.h"

int main(int argc, char **argv)
{
    long result = 0;
    if (argc != 4) {
        fprintf(stderr, "usage: %s add|sub|mul|div|mod A B\n", argv[0]);
        return 2;
    }
    log_msg(LOG_APP_START, NULL);
    switch (calc_eval(argv[1], strtol(argv[2], NULL, 10), strtol(argv[3], NULL, 10), &result)) {
    case CALC_OK:
        printf("%ld\n", result);
        log_msg(LOG_CALC_RESULT, NULL);
        return 0;
    case CALC_DIV_ZERO:
        log_msg(LOG_CALC_DIV_ZERO, NULL);
        return 1;
    default:
        log_msg(LOG_CALC_BAD_OP, argv[1]);
        return 1;
    }
}
