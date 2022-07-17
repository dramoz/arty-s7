///////////////////////////////////////////////////////////////////////////////
// File: arty_s7_test.sv
// Copyright (c) 2022. Danilo Ramos
// All rights reserved.
// This license message must appear in all versions of this code including
// modified versions.
////////////////////////////////////////////////////////////////////////////////
// Overview
// Simple Arty S7 test
// SW[n] -> LED[n]
// Counter -> RGB red-leds PWM enable
// Buttons -> RGB green-, blue-leds PWM enable
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module arty_s7_test_wrapper
#(
  parameter CLK_FREQ = 12000000
)
(
  input  wire   rst,  // reset, active low (top right, red button)
  input  wire   clk,  // 12 MHz, ~83.33ns
  
  input  wire [3:0] sw,  // Switches
  input  wire [3:0] btn, // buttons
  
  output wire [3:0] led,
  output wire       led0_r,
  output wire       led0_g,
  output wire       led0_b,
  output wire       led1_r,
  output wire       led1_g,
  output wire       led1_b
);

arty_s7_test
#(
  .CLK_FREQ(CLK_FREQ)
)
arty_s7_test_inst
(
  .rst(rst),
  .clk(clk),
  .sw(sw),
  .btn(btn),
  .led(led),
  .led0_r(led0_r),
  .led0_g(led0_g),
  .led0_b(led0_b),
  .led1_r(led1_r),
  .led1_g(led1_g),
  .led1_b(led1_b)
);

endmodule

`default_nettype wire
