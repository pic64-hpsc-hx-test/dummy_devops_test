/* (c) 2026 Microchip Technology Inc. SPDX-License-Identifier: MIT */
#include <stdio.h>
#include "log.h"

void log_msg(log_id_t id, const char *detail)
{
    const log_def_t *d = &log_defs[id];
    fprintf(stderr, "[%s] %s: %s%s%s\n", d->level, d->name, d->text, detail ? " " : "", detail ? detail : "");
}
