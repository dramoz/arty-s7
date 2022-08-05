# ============================================================================
#  Arty-S7 Test - CoCoTB Verif. TB
#  Copyright (c) 2022.  Danilo Ramos
#  All rights reserved.
#  This license message must appear in all versions of this code including
#  modified versions.
#  Licensed under the MIT license.
# ============================================================================

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.utils import get_sim_time

CLK_FREQ = 100e6

async def init(dut, clk_period, units):
  dut.resetn.value = 0
  dut.clk.value    = 0
  
  dut.sw.value      = 0
  dut.btn.value     = 0
  dut.uart_rx.value = 0
  dut.frnt_dst_sens_edge.value = 0
  
  cocotb.start_soon(Clock(signal=dut.clk, period=clk_period, units="ns").start())
  

async def reset(dut, clk_cycles=12):
  dut.resetn.value = 0
  for _ in range(clk_cycles):
    await RisingEdge(dut.clk)
    
  dut.resetn.value = 1

async def fake_distance(dut):
  while True:
    await RisingEdge(dut.frnt_dst_sens_trigger)
    
    sim_time = get_sim_time('us')
    await FallingEdge(dut.frnt_dst_sens_trigger)
    
    dut._log.info(f"got trigge pulse of {int(get_sim_time('us') - sim_time)} us")
    dut.frnt_dst_sens_edge.value = 1
    
    edge_echo = random.randint(60, 600)
    dut._log.info(f"generating echo/edge of {edge_echo} us")
    await Timer( edge_echo, units='us')
    
    dut._log.info(f"estimated distance {(340*edge_echo*1e-6*100):.2f} cm")
    dut.frnt_dst_sens_edge.value = 0
    
@cocotb.test()
async def free_run_arty_s7_atrover(dut, times=1000, duration=10, units='us'):
  """Just let it run a few microseconds"""
  
  clk_period = int(1e9/CLK_FREQ)
  await init(dut, clk_period=clk_period, units="ns")
  
  dut._log.info(f"Running {duration} {units} (CLK_FREQ:{(CLK_FREQ/1e6)} MHz, CLK_PERIOD: {clk_period} ns)")
  await reset(dut, clk_cycles=10000)
  await Timer(400, units='us')
  
  cocotb.start_soon(fake_distance(dut))
  
  btn_sw = 0
  for inx in range(times):
    btn = btn_sw & 0x0f
    sw  = (btn_sw & 0xf0) >> 4
    btn_sw += 1
    
    dut.btn.value = btn
    dut.sw.value = sw
    if (inx % 10) == 0:
      dut._log.info(f"{inx}/{times} | btn: {btn} | sw: {sw}")
    
    await Timer(duration, units=units)
    
  dut._log.info("Done...")
  