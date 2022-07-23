///////////////////////////////////////////////////////////////////////////////
// File: main.cpp
// Copyright (c) 2022. Danilo Ramos
// All rights reserved.
// This license message must appear in all versions of this code including
// modified versions.
////////////////////////////////////////////////////////////////////////////////
// Overview
// Arty-S7-ROVER FW
////////////////////////////////////////////////////////////////////////////////

#include<cstdint>
#include "memory_map.h"

const uint32_t CLK_FREQ     = 100000000;
const uint32_t RGB_PWM_FREQ =     20000;
const uint32_t RGB_DCYLE  = uint32_t(0.01 * CLK_FREQ/RGB_PWM_FREQ);

const uint32_t MOTOR_PWM_FREQ   = 500;
const uint32_t MOTOR_FULL_STOP  = 0;
const uint32_t MOTOR_SLOW_SPEED = uint32_t(0.3 * CLK_FREQ/MOTOR_PWM_FREQ);
const uint32_t MOTOR_MEDIUM_SPEED = uint32_t(0.5 * CLK_FREQ/MOTOR_PWM_FREQ);
const uint32_t MOTOR_HIGH_SPEED = uint32_t(0.8 * CLK_FREQ/MOTOR_PWM_FREQ);

const uint32_t UART_MASK    = 0x80000000;

int main(void) {
  // LEDs
  uint32_t leds_st = 1;
  uint32_t rgb0 = 1;
  uint32_t rgb1 = 1;
  
  // IOs
  uint32_t btn = 0;
  uint32_t sw  = 0;
  
  // Setup Motors PWMs
  uint32_t dir_rpt = (uint32_t)('s');  // s:stop, f:forward, b:backward, l:left, r:right
  uint32_t motor_curr_speed = MOTOR_FULL_STOP;
  WRITE_IO(M0_BWD_PWM_REG, MOTOR_FULL_STOP);
  WRITE_IO(M0_FWD_PWM_REG, MOTOR_FULL_STOP);
  WRITE_IO(M1_BWD_PWM_REG, MOTOR_FULL_STOP);
  WRITE_IO(M1_FWD_PWM_REG, MOTOR_FULL_STOP);
  
  // Setup RGBs to low intensity
  WRITE_IO(RGB0_DCYCLE_REG, RGB_DCYLE);
  WRITE_IO(RGB1_DCYCLE_REG, RGB_DCYLE);
  
  // Turn on LEDs 1 to ACK PWR and RISCV boot OK.
  WRITE_IO(LEDS_REG, leds_st);
  
  // UART Hello World
  const char* hello_msg = "Arty-S7 ROVER (VexRiscv)\r\n";
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
    
    // DC motors
    // Select speed from SW
    if(sw==0) {
      motor_curr_speed = MOTOR_SLOW_SPEED;
    }
    else if(sw==0xf){
      motor_curr_speed = MOTOR_HIGH_SPEED;
    }
    else {
      motor_curr_speed = MOTOR_MEDIUM_SPEED;
    }
    
    // Select direction from button
    // Prioritize as only one setting is possible
    leds_st = btn;
    if(btn & 0x1) {
      // Move FWD
      dir_rpt = (uint32_t)('f');
      WRITE_IO(M0_BWD_PWM_REG, MOTOR_FULL_STOP);
      WRITE_IO(M0_FWD_PWM_REG, motor_curr_speed);
      WRITE_IO(M1_BWD_PWM_REG, MOTOR_FULL_STOP);
      WRITE_IO(M1_FWD_PWM_REG, motor_curr_speed);
    }
    else if(btn & 0x2) {
      // Move BKD
      dir_rpt = (uint32_t)('b');
      WRITE_IO(M0_BWD_PWM_REG, motor_curr_speed);
      WRITE_IO(M0_FWD_PWM_REG, MOTOR_FULL_STOP);
      WRITE_IO(M1_BWD_PWM_REG, motor_curr_speed);
      WRITE_IO(M1_FWD_PWM_REG, MOTOR_FULL_STOP);
    }
    else if(btn & 0x4) {
      // Move Right
      dir_rpt = (uint32_t)('r');
      WRITE_IO(M0_BWD_PWM_REG, MOTOR_FULL_STOP);
      WRITE_IO(M0_FWD_PWM_REG, motor_curr_speed);
      WRITE_IO(M1_BWD_PWM_REG, motor_curr_speed);
      WRITE_IO(M1_FWD_PWM_REG, MOTOR_FULL_STOP);
    }
    else if(btn & 0x8) {
      // Move Left
      dir_rpt = (uint32_t)('l');
      WRITE_IO(M0_BWD_PWM_REG, motor_curr_speed);
      WRITE_IO(M0_FWD_PWM_REG, MOTOR_FULL_STOP);
      WRITE_IO(M1_BWD_PWM_REG, MOTOR_FULL_STOP);
      WRITE_IO(M1_FWD_PWM_REG, motor_curr_speed);
    }
    else {
      // Stop
      dir_rpt = 0;
      WRITE_IO(M0_BWD_PWM_REG, MOTOR_FULL_STOP);
      WRITE_IO(M0_FWD_PWM_REG, MOTOR_FULL_STOP);
      WRITE_IO(M1_BWD_PWM_REG, MOTOR_FULL_STOP);
      WRITE_IO(M1_FWD_PWM_REG, MOTOR_FULL_STOP);
    }
    
    // Update LEDs
    WRITE_IO(LEDS_REG, leds_st);
    WRITE_IO(RGB0_REG, rgb0);
    WRITE_IO(RGB1_REG, rgb1);
    
    // UART
    if(!pending_tx) {
      uart_rx = READ_IO(UART0_RX_REG);
    }
    
    // Echo
    if(uart_rx & UART_MASK) {
      uart_tx = READ_IO(UART0_TX_REG);
      if((uart_tx & UART_MASK)==0) {
        WRITE_IO(UART0_TX_REG, uart_rx);
        pending_tx = false;
        uart_rx = 0;
      }
      else {
        pending_tx = true;
      }
    }
    else {
      // Report
      if(!pending_tx) {
        if(dir_rpt) {
          WRITE_IO(UART0_TX_REG, dir_rpt | UART_MASK);
          dir_rpt = 0;
        }
      }
    }
  };
  
  return 0;
}
