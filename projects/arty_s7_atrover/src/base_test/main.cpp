///////////////////////////////////////////////////////////////////////////////
// File: main.cpp
// Copyright (c) 2022. Danilo Ramos
// All rights reserved.
// This license message must appear in all versions of this code including
// modified versions.
////////////////////////////////////////////////////////////////////////////////
// Overview
// Base FW test
////////////////////////////////////////////////////////////////////////////////

#include<cstdint>
#include "memory_map.h"

const uint32_t CLK_FREQ     = 100000000;
const uint32_t RGB_PWM_FREQ =     20000;
const uint32_t UART_MASK    = 0x80000000;

const uint32_t RGB_LOW    = uint32_t(0.01 * CLK_FREQ/RGB_PWM_FREQ);
const uint32_t RGB_MEDIUM = uint32_t(0.1 * CLK_FREQ/RGB_PWM_FREQ);
const uint32_t RGB_HIGH   = uint32_t(0.2 * CLK_FREQ/RGB_PWM_FREQ);

int main(void) {
  uint32_t leds_st = 1;
  uint32_t btn = 0;
  uint32_t sw  = 0;
  
  // Setup
  WRITE_IO(RGB0_DCYCLE_REG, RGB_MEDIUM);
  WRITE_IO(RGB1_DCYCLE_REG, RGB_MEDIUM);
  
  // Turn on some LEDs to ACK PWR on
  WRITE_IO(LEDS_REG, leds_st);
  
  // UART Hello World
  const char* hello_msg = "Hello Arty-S7 + VexRiscv!\r\n";
  uint32_t inx = 0;
  
  bool pending_tx;
  uint32_t uart_rx;
  uint32_t uart_tx;
  
  while(hello_msg[inx]!=0) {
    uart_tx = READ_IO(UART0_TX_REG);
    if((uart_tx & UART_MASK)==0) {
      WRITE_IO(UART0_TX_REG, (uint32_t)hello_msg[inx] | UART_MASK);
      ++inx;
    }
  };
  
  // Loop forever
  pending_tx = false;
  uart_rx = 0;
  for(;;) {
    btn = READ_IO(BUTTONS_REG);
    sw  = READ_IO(SWITCHES_REG);
    
    /* Keep this one always on */
    if(btn & 0x1)
      leds_st &= ~0x1;
    else
      leds_st |= 0x1;
    
    if(btn & 0x2)
      leds_st |= 0x2;
    else
      leds_st &= ~0x2;
      
    if(btn & 0x4)
      leds_st |= 0x4;
    else
      leds_st &= ~0x4;
    
    if(btn & 0x8)
      leds_st |= 0x8;
    else
      leds_st &= ~0x8;
    
    if(sw & 0x8) {
      WRITE_IO(RGB0_DCYCLE_REG, RGB_LOW);
      WRITE_IO(RGB1_DCYCLE_REG, RGB_HIGH);
    } else {
      WRITE_IO(RGB0_DCYCLE_REG, RGB_MEDIUM);
      WRITE_IO(RGB1_DCYCLE_REG, RGB_MEDIUM);
    }
    
    // Update LEDs
    WRITE_IO(LEDS_REG, leds_st);
    WRITE_IO(RGB0_REG,  sw & 0x07);
    WRITE_IO(RGB1_REG, ~sw & 0x07);
    
    // UART
    if(!pending_tx) {
      uart_rx = READ_IO(UART0_RX_REG);
    }
    
    if(uart_rx & UART_MASK) {
      uart_tx = READ_IO(UART0_TX_REG);
      if((uart_tx & UART_MASK)==0) {
        WRITE_IO(UART0_TX_REG, uart_rx+1);
        pending_tx = false;
        uart_rx = 0;
      }
      else {
        pending_tx = true;
      }
    }
  };
  
  return 0;
}
