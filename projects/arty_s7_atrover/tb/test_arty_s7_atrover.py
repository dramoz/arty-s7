# ============================================================================
#  Arty-S7 Test - CoCoTB Verif. TB
#  Copyright (c) 2022.  Danilo Ramos
#  All rights reserved.
#  This license message must appear in all versions of this code including
#  modified versions.
#  Licensed under the MIT license.
# ============================================================================

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

CLK_FREQ = 100e6

async def init(dut, clk_period, units):
  dut.resetn.value = 0
  dut.clk.value    = 0
  
  dut.sw.value      = 0
  dut.btn.value     = 0
  dut.uart_rx.value = 0
  
  cocotb.start_soon(Clock(signal=dut.clk, period=clk_period, units="ns").start())
  

async def reset(dut, clk_cycles=12):
  dut.resetn.value = 0
  for _ in range(clk_cycles):
    await RisingEdge(dut.clk)
    
  dut.resetn.value = 1

@cocotb.test()
async def io_test_arty_s7_atrover(dut):
  """Just let it run a few microseconds"""
  
  clk_period = int(1e9/CLK_FREQ)
  await init(dut, clk_period=clk_period, units="ns")
  
  dut._log.info(f"Running simple IO test (CLK_FREQ:{(CLK_FREQ/1e6)} MHz, CLK_PERIOD: {clk_period} ns)")
  await reset(dut)
  await Timer(1, units='us')
  
  dut._log.info("Set btn=0x01")
  dut.btn.value = 0x1
  await Timer(1, units='us')
  
  dut._log.info("Set btn=0x02")
  dut.btn.value = 0x2
  await Timer(1, units='us')
  
  dut._log.info("Set btn=0x03")
  dut.btn.value = 0x3
  await Timer(1, units='us')
  
  dut._log.info("Set sw=0x0f")
  dut.sw.value = 0xf
  await Timer(1, units='us')
  
  dut._log.info("Set sw=0x02")
  dut.sw.value = 0x2
  await Timer(1, units='us')
  
  dut._log.info("EOS (10us)")
  await Timer(10, units='us')
  dut._log.info("Done...")
  