#!/bin/bash
# (c) 2026 Microchip Technology Inc.
# SPDX-License-Identifier: MIT
# Runs every case in tests/regression/cases/*.txt against a dummy_app binary and writes JUnit XML.
# Usage: run_regression.sh <dummy_app> [junit.xml]
# Honours REGRESSION_SECONDS and FLAKY_PERCENT (from ci/sim.env, or the environment).
set -u
app=${1:?usage: run_regression.sh <dummy_app> [junit.xml]}
junit=${2:-regression-results.xml}
here=$(cd "$(dirname "$0")" && pwd)
# ci/sim.env gives the defaults; a value already in the environment wins (e.g. REGRESSION_SECONDS=0 locally)
sim_get() { sed -n "s/^$1=\([0-9]*\).*/\1/p" "$here/../../ci/sim.env" 2>/dev/null; }
REGRESSION_SECONDS=${REGRESSION_SECONDS:-$(sim_get REGRESSION_SECONDS)}
FLAKY_PERCENT=${FLAKY_PERCENT:-$(sim_get FLAKY_PERCENT)}
REGRESSION_SECONDS=${REGRESSION_SECONDS:-0}
FLAKY_PERCENT=${FLAKY_PERCENT:-0}

total=0; failed=0; cases=""
for f in "$here"/cases/*.txt; do
    while IFS='|' read -r args want rc; do
        args=$(echo "$args" | xargs); want=$(echo "$want" | xargs); rc=$(echo "$rc" | xargs)
        case "$args" in ''|'#'*) continue ;; esac
        total=$((total + 1))
        got=$("$app" $args 2>/dev/null); got_rc=$?
        name="$(basename "$f" .txt): $args"
        if [ "$got" != "$want" ] || [ "$got_rc" != "$rc" ]; then
            failed=$((failed + 1)); echo "FAIL $name: got '$got' rc $got_rc, want '$want' rc $rc"
            cases+="<testcase classname=\"regression\" name=\"$name\"><failure message=\"got '$got' rc $got_rc\"/></testcase>"
        else
            echo "ok   $name"; cases+="<testcase classname=\"regression\" name=\"$name\"/>"
        fi
    done < "$f"
done
if [ "$FLAKY_PERCENT" -gt 0 ] && [ $((RANDOM % 100)) -lt "$FLAKY_PERCENT" ]; then
    total=$((total + 1)); failed=$((failed + 1)); echo "FAIL flaky: random failure (FLAKY_PERCENT=$FLAKY_PERCENT)"
    cases+="<testcase classname=\"regression\" name=\"flaky\"><failure message=\"random failure\"/></testcase>"
fi
if [ "$REGRESSION_SECONDS" -gt 0 ]; then echo "simulating a long regression: sleep ${REGRESSION_SECONDS}s"; sleep "$REGRESSION_SECONDS"; fi
echo "<testsuite name=\"dummy-regression\" tests=\"$total\" failures=\"$failed\">$cases</testsuite>" > "$junit"
echo "$total case(s), $failed failure(s)"
[ "$failed" -eq 0 ]
