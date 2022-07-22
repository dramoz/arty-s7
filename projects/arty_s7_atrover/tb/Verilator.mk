# =========================================================================================
#  Arty-S7 Test Makefile
#  Copyright (c) 2022 Danilo Ramos
#  All rights reserved.
#  Licensed under the MIT license.
# =========================================================================================
# https://www.gnu.org/software/make/manual/html_node/index.html#SEC_Contents
# =========================================================================================

################################################################################
# DUT
UUT ?= arty_s7_atrover
RTL_FILES ?= rtlfiles.lst
CPP_FILES ?= cppfiles.lst
OBJ_DIR ?= obj_dir

# Parameters

DUT_PARAMS_LST = 
DUT_PARAMS = $(foreach param,$(DUT_PARAMS_LST), $(param)=$($(param)))
################################################################################
# CPP Compiler flags
CFLAGS ?= 
CFLAGS += -std=c++14

# Enable debug mode (Pass to g++)
# - GDB=1 -> Enable GDB (C GNU debugg info) -> run> gdb --args executable arg1 arg2 ... argN\\n"
ifdef GDB
  CFLAGS += -g
endif
#- DEBUG=1 -> Enable CPP/SV debug mode (verbose)\\n"
ifdef DEBUG
  CFLAGS += -D_DEBUG
endif
ifdef VL_DEBUG
  CFLAGS += -DVL_DEBUG=$(VL_DEBUG)
endif
# CPP linker flags
LDFLAGS += -lz

################################################################################
# Check for sanity to avoid later confusion
ifneq ($(words $(CURDIR)),1)
 $(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif

######################################################################
# Set up variables
# If $VERILATOR_ROOT isn't in the environment, we assume it is part of a
# package install, and verilator is in your path. Otherwise find the
# binary relative to $VERILATOR_ROOT (such as when inside the git sources).
ifeq ($(VERILATOR_ROOT),)
  VERILATOR = verilator
  VERILATOR_COVERAGE = verilator_coverage
else
  export VERILATOR_ROOT
  VERILATOR = $(VERILATOR_ROOT)/bin/verilator
  VERILATOR_COVERAGE = $(VERILATOR_ROOT)/bin/verilator_coverage
endif

################################################################################
# Verilator Flags
VERILATOR_FLAGS ?= 
VERILATOR_FLAGS += --x-initial 0
RUN_FLAGS ?= ""

ifdef SPEED_UP
  VERILATOR_FLAGS += -O3
  VERILATOR_FLAGS += --noassert
  VERILATOR_FLAGS += --x-assign fast
else
  VERILATOR_FLAGS += --stats --stats-vars
  ifdef DEBUG
    VERILATOR_FLAGS += +define+_DEBUG
    VERILATOR_FLAGS += -O0
    VERILATOR_FLAGS += --assert
  endif
  ifdef COVERAGE
    VERILATOR_FLAGS += --coverage
    VERILATOR_FLAGS += --x-assign 0
  else
    VERILATOR_FLAGS += --x-assign unique
  endif
endif

# Verilog
VERILATOR_FLAGS += --cc -f $(RTL_FILES) --top-module $(UUT)
VERILATOR_IGNORE_WARNINGS = fatal UNOPT UNOPTFLAT UNUSED WIDTH TIMESCALEMOD CASEINCOMPLETE
#VERILATOR_IGNORE_WARNINGS := $(addprefix -Wno-,$(VERILATOR_IGNORE_WARNINGS))
VERILATOR_FLAGS += -Wall
VERILATOR_FLAGS += $(addprefix -Wno-,$(VERILATOR_IGNORE_WARNINGS))

# Multi-threading
threads := $(shell nproc)
threads := $(shell expr $(threads) - 2)
ifdef WAVES
  ifdef FST
    CFLAGS += -DTRACE_FST
    VERILATOR_FLAGS += --trace-fst
  else
    CFLAGS += -DTRACE_VCD
    VERILATOR_FLAGS += --trace
  endif
  threads := $(shell expr $(threads) - 1)
  VERILATOR_FLAGS += --trace-structs --trace-threads 1
  RUN_FLAGS += +trace
endif
VERILATOR_FLAGS += --threads $(threads)

# Extend extensions to .v .sv .vh .svh
VERILATOR_FLAGS += +librescan +libext+.v+.sv+.vh+.svh

# Add directories for modules, include files or libraries
VERILATOR_FLAGS +=  -y .

# Generate C++ in executable form
VERILATOR_FLAGS += $(addprefix -G,$(DUT_PARAMS)) $(addprefix -CFLAGS ,$(CFLAGS)) -Mdir $(OBJ_DIR) --exe -f $(CPP_FILES) $(addprefix -LDFLAGS ,$(LDFLAGS))
MK_FILE = V$(UUT).mk

$(info ****************************************************************************************************)
$(info ****************************************************************************************************)

################################################################################
#Rules
default: all

all: run

.PHONY: verilate
verilate:
	@echo "------------------------------ VERILATE ------------------------------"
	$(VERILATOR) $(VERILATOR_FLAGS)  

compile: verilate
	@echo
	@echo "------------------------------ COMPILE ------------------------------"
	$(MAKE) -j $(shell nproc) -C $(OBJ_DIR) -f $(MK_FILE)

run: compile
	@echo
	@echo "------------------------------ RUN ------------------------------"
	@mkdir -p logs
	$(OBJ_DIR)/V$(UUT)
	

coverage: run
	@echo
	@echo "------------------------------ COVERAGE ------------------------------"
	@rm -fr logs/annotated
	$(VERILATOR_COVERAGE) --annotate logs/annotated logs/coverage.dat

################################################################################
# Other rules
options:
	# make options
	@echo -e $(VALID_OPTIONS)

lint:
	$(VERILATOR) --lint-only -f $(RTL_FILES) --top-module $(UUT) -Wno-fatal -Wall

debug:
	@echo "NOT IMPLEMENTED (define DEBUG in .sv/.cpp files)!!!"
	
tree:
	VERILATOR_FLAGS += --dump-tree
	$(MAKE) verilate
	
show-config:
	$(VERILATOR) -V

maintainer-copy::
clean mostlyclean distclean maintainer-clean::
	rm -rf $(OBJ_DIR) logs *.log *.dmp *.vpd coverage.dat core
