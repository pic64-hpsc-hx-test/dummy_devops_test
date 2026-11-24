# (c) 2026 Microchip Technology Inc.
# SPDX-License-Identifier: MIT
CC      ?= gcc
CFLAGS  ?= -O2 -Wall -Wextra -Werror -std=c11
BUILD   := build
SRCS    := src/main.c src/calc.c src/log.c src/generated/logs.c
VERSION ?= 0.0.0

.PHONY: all check-generated unit-tests regression package clean

all: $(BUILD)/dummy_app

$(BUILD)/dummy_app: $(SRCS) src/*.h src/generated/logs.h
	@mkdir -p $(BUILD)
	$(CC) $(CFLAGS) -Isrc -o $@ $(SRCS)

check-generated:
	python3 tools/gen_logs.py --check

$(BUILD)/test_calc: tests/unit/test_calc.c src/calc.c src/calc.h
	@mkdir -p $(BUILD)
	$(CC) $(CFLAGS) -Isrc -o $@ tests/unit/test_calc.c src/calc.c

unit-tests: $(BUILD)/test_calc
	$(BUILD)/test_calc

regression: $(BUILD)/dummy_app
	tests/regression/run_regression.sh $(BUILD)/dummy_app $(BUILD)/regression-results.xml

# The artifact the regression job downloads (the p64h_sysc_*.internal.tar.gz equivalent)
package: $(BUILD)/dummy_app
	tar -czf $(BUILD)/devops_dummy_project_$(VERSION).tar.gz -C $(BUILD) dummy_app

clean:
	rm -rf $(BUILD)
