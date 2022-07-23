# ============================================================================
#  CocoTB Makefile
#  Copyright (c) 2022.  Danilo Ramos
#  All rights reserved.
#  This license message must appear in all versions of this code including
#  modified versions.
#  Licensed under the MIT license.
# ============================================================================
# make {SIM=verilator|icarus} {WAVES=1} {COVERAGE=1}
# options:
#  RANDOM_SEED=1234
#  COCOTB_LOG_LEVEL=[DEBUG|INFO|WARNING|ERROR|CRITICAL]
#  TESTCASE=name_of_test_case_aka_function_to_run (decorated with cocotb.test)
#  COCOTB_RESOLVE_X=[VALUE_ERROR, ZEROS, ONES, RANDOM]
#    -> set to RANDOM (instead of CoCoTB default VALUE_ERROR)
#  PLUSARGS=+args (Verilog/SV)
# ============================================================================
# -----------------------------------------------------------------------
TOPLEVEL_LANG ?= verilog
TOPLEVEL ?= arty_s7_atrover
MODULE ?= test_free_run_arty_s7_atrover
SIM ?= verilator
RTL_FILES ?= rtlfiles.lst

# -----------------------------------------------------------------------
# Common sim parameters
COCOTB_HDL_TIMEUNIT = 100ps
COCOTB_HDL_TIMEPRECISION = 1ps
$(info simulation time(unit/precision): $(COCOTB_HDL_TIMEUNIT)/$(COCOTB_HDL_TIMEPRECISION) )
export COCOTB_RESOLVE_X ?= RANDOM
$(info RESOLVE_X set to $(COCOTB_RESOLVE_X))

# Disable short formating for debug
export COCOTB_REDUCED_LOG_FMT ?= 0

# -----------------------------------------------------------------------
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

# -----------------------------------------------------------------------
# Select wave output format (FST) default, set WAVE_FMT=vcd to select vcd
WAVE_FMT ?= fst
ifeq ($(WAVE_FMT), fst)
  TRACE_ARG = -fst
else
  TRACE_ARG = 
endif

# -----------------------------------------------------------------------
# Load RTL files
FILES := $(shell cat $(RTL_FILES))
VERILOG_SOURCES := $(FILES)
$(info Verilog files: )
$(info $(VERILOG_SOURCES) )

# -----------------------------------------------------------------------
# top-lvl parameters
export HW_PARAM_CLK_FREQ        ?= 100000000
export HW_PARAM_RISCV_RAM_DEPTH ?= 8192
export HW_PARAM_RISCV_WL        ?= 32
export HW_PARAM_RISCV_TEXT      ?= '"../vexriscv_generator/VexRiscvBase/build/main.mem"'
# -----------------------------------------------------------------------
# --------------------------------------
# - Verilator -
ifeq ($(SIM), verilator)
  $(info ------------------)
  $(info CoCoTB + Verilator)
  COMPILE_ARGS += -I../rtl
  # Supress common anoying verilator warnings (unnecessary here for sim, not linting)
  EXTRA_ARGS += -Wno-fatal -Wall
  # -Wno-UNOPT -Wno-UNOPTFLAT -Wno-UNUSED -Wno-WIDTH
  EXTRA_ARGS += --assert
  # --------------------------------------
  # top-lvl parameters
  EXTRA_ARGS += -GCLK_FREQ=$(HW_PARAM_CLK_FREQ)
  EXTRA_ARGS += -GRISCV_RAM_DEPTH=$(HW_PARAM_RISCV_RAM_DEPTH)
  EXTRA_ARGS += -GRISCV_WL=$(HW_PARAM_RISCV_WL)
  EXTRA_ARGS += -GRISCV_TEXT=$(HW_PARAM_RISCV_TEXT)
  
  # --------------------------------------
  # wave | coverage
  ifeq ($(WAVES), 1)
    $(info + wave ($(VCD)))
    EXTRA_ARGS += --trace$(TRACE_ARG) --trace-structs
  endif
  ifeq ($(COVERAGE), 1)
    $(info + coverage)
    EXTRA_ARGS += --coverage
  endif
  $(info ------------------)
endif

# - Icarus -
ifeq ($(SIM), icarus)
  $(info ------------------)
  $(info CoCoTB + Icarus)
  # --------------------------------------
  # top-lvl parameters
  COMPILE_ARGS += -P $(TOPLEVEL).CLK_FREQ=$(HW_PARAM_CLK_FREQ)
  COMPILE_ARGS += -P $(TOPLEVEL).CLK_FREQ=$(HW_PARAM_CLK_FREQ)
  COMPILE_ARGS += -P $(TOPLEVEL).RISCV_RAM_DEPTH=$(HW_PARAM_RISCV_RAM_DEPTH)
  COMPILE_ARGS += -P $(TOPLEVEL).RISCV_WL=$(HW_PARAM_RISCV_WL)
  COMPILE_ARGS += -P $(TOPLEVEL).RISCV_TEXT=$(HW_PARAM_RISCV_TEXT)
  # --------------------------------------
  # wave
  ifeq ($(WAVES), 1)
    $(info + wave (fst))
    PLUSARGS += -$(WAVE_FMT)
    ICARUS_WAVE = icarus_wave.v
    VERILOG_SOURCES += $(ICARUS_WAVE)
    COMPILE_ARGS += -s icarus_wave
    # --------------------------------------
    # generate Icarus wave module
    # from CoCoTB
    $(file >  $(ICARUS_WAVE), module icarus_wave();)
    $(file >> $(ICARUS_WAVE), initial begin)
    $(file >> $(ICARUS_WAVE),     $$dumpfile("dump.$(WAVE_FMT)");)
    $(file >> $(ICARUS_WAVE),     $$dumpvars(0, $(TOPLEVEL));)
    $(file >> $(ICARUS_WAVE),     #1;)
    $(file >> $(ICARUS_WAVE), end)
    $(file >> $(ICARUS_WAVE), endmodule)
  endif
  $(info ------------------)
endif

# --------------------------------------------------------------
$(info Starting CoCoTB... )
include $(shell cocotb-config --makefiles)/Makefile.sim

# --------------------------------------------------------------
.PHONY: clean
clean::
	rm -fr __pycache__ sim_build
	rm -fr `find ../ -name "__pycache__"`
	rm -rf iverilog_dump.v
	rm -rf dump.$(WAVE_FMT)*
