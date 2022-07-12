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

module arty_s7_test(
  input  wire        rst,  // reset, active low (top right, red button)
  input  wire        clk,  // 12 MHz, ~83.33ns
  
  input  wire  [3:0] sw,  // Switches
  input  wire  [3:0] btn, // buttons
  
  output logic [3:0] led,
  output logic       led0_r,
  output logic       led0_g,
  output logic       led0_b,
  output logic       led1_r,
  output logic       led1_g,
  output logic       led1_b
);

localparam CLK_FREQ = 12000000;
localparam RLED_PWM_FREQ = 5000;
localparam RLED_PWM_DCYCLE = int'(0.25*RLED_PWM_FREQ);
localparam GLED_PWM_FREQ = 10000;
localparam GLED_PWM_DCYCLE = int'(0.50*GLED_PWM_FREQ);
localparam BLED_PWM_FREQ = 20000;
localparam BLED_PWM_DCYCLE = int'(0.75*BLED_PWM_FREQ);

logic [23:0] rled_cnt = '0;  // 1s -> 12e6 -> log2(): 24bits

logic rled_pwm;
logic gled_pwm;
logic bled_pwm;

always_ff @( posedge clk ) begin : rled_cnt_proc
  if (!rst) begin
    rled_cnt  <= '0;
    led       <= '0;
  end else begin
    rled_cnt <= rled_cnt + 1;
    //led <= rled_cnt[23:20];
    led      <= sw;
  end  // rst
end // rled_cnt_proc

//assign led0_r = 1'b0;
//assign led1_r = 1'b0;
//assign led0_g = 1'b0;
//assign led0_b = 1'b0;
//assign led1_g = 1'b0;
//assign led1_b = 1'b0;
pwm
#(
  .CLK_FREQ(CLK_FREQ),
  .PWM_FREQ(RLED_PWM_FREQ)
)
rled_pwm_inst
(
  .clk(clk),
  .rst(rst),
  .i_duty_cycle(RLED_PWM_DCYCLE),
  .o_pwm(rled_pwm)
);
assign led0_r = (rled_cnt[23] == 1'b1) ? (rled_pwm) : (1'b0);
assign led1_r = (rled_cnt[22] == 1'b1) ? (rled_pwm) : (1'b0);

pwm
#(
  .CLK_FREQ(CLK_FREQ),
  .PWM_FREQ(GLED_PWM_FREQ)
)
gled_pwm_inst
(
  .clk(clk),
  .rst(rst),
  .i_duty_cycle(GLED_PWM_DCYCLE),
  .o_pwm(gled_pwm)
);
assign led0_g = (btn[0]==1'b1) ? (gled_pwm) : (1'b0);
assign led1_g = (btn[1]==1'b1) ? (gled_pwm) : (1'b0);

pwm
#(
  .CLK_FREQ(CLK_FREQ),
  .PWM_FREQ(BLED_PWM_FREQ)
)
bled_pwm_inst
(
  .clk(clk),
  .rst(rst),
  .i_duty_cycle(BLED_PWM_DCYCLE),
  .o_pwm(bled_pwm)
);
assign led0_b = (btn[2]==1'b1) ? (bled_pwm) : (1'b0);
assign led1_b = (btn[3]==1'b1) ? (bled_pwm) : (1'b0);

endmodule: arty_s7_test

`default_nettype wire
