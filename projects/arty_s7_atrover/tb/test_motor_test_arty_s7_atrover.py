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
from cocotb.triggers import Timer, RisingEdge, ClockCycles

CLK_FREQ = 100e6

async def init(dut, clk_period, units):
  dut.resetn.value = 0
  dut.clk.value    = 0
  
  dut.sw.value      = 0
  dut.btn.value     = 0
  dut.uart_rx.value = 1
  
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
  
  dut._log.info(f"Running DC motor test (CLK_FREQ:{(CLK_FREQ/1e6)} MHz, CLK_PERIOD: {clk_period} ns)")
  await reset(dut)
  await Timer(1, units='us')
  
  # Wait Hellor World msg
  msg_len = 27
  sim_byte_tx_tm = 8700
  uart_tx_wait_time = 1 + (msg_len * sim_byte_tx_tm) / 1000
  await Timer(uart_tx_wait_time, units='us')
  
  SPEED_CHANGE_WAIT = 20
  for sw in [1, 2, 4, 8, 13, 15]: #range(1, 16):
    dut._log.info(f"Speed (sw): {sw}")
    dut.sw.value = sw
    
    dut._log.info("FWD(btn=1)")
    dut.btn.value = 0x1
    await Timer(SPEED_CHANGE_WAIT, units='us')
    
    dut._log.info("BWD(btn=2)")
    dut.btn.value = 0x2
    await Timer(SPEED_CHANGE_WAIT, units='us')
    
    dut._log.info("Right(btn=4)")
    dut.btn.value = 0x4
    await Timer(SPEED_CHANGE_WAIT, units='us')
    
    dut._log.info("Left(btn=8)")
    dut.btn.value = 0x8
    await Timer(SPEED_CHANGE_WAIT, units='us')
    
    dut._log.info("Stop(btn=0)")
    dut.btn.value = 0x0
    await Timer(SPEED_CHANGE_WAIT/2, units='us')
  
  # Test that only one OP is selected
  dut._log.info("BWD(btn=6)")
  dut.btn.value = 0x6
  await Timer(SPEED_CHANGE_WAIT, units='us')
  
  # EOS
  dut._log.info("EOS (10us)")
  await Timer(10, units='us')
  dut._log.info("Done...")
  