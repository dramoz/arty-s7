#include "cpu_layout.h"
#include "macros.S"

.section .text

.equ _start_address, 0x00000000
.equ _sim_done_address, 0x00000010
.equ _trap_address, 0x00000020

.global _start
.org START_ADDRESS
_start:
  j _start_continue

.org END_LOOP_ADDRESS
_all_done:
  j	_all_done

.org TRAP_ADDRESS
.global trap
_trap: 
  push_regs
  call trap
  pop_regs
  
  mret

.global __stack_start
.global main
_start_continue:
  la sp, __stack_start
  
  jal ra,main
  j	_all_done
  nop
  nop
  nop
  
  ebreak

