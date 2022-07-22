///////////////////////////////////////////////////////////////////////////////
// File: pwm.sv
// Copyright (c) 2022. Danilo Ramos
// All rights reserved.
// This license message must appear in all versions of this code including
// modified versions.
////////////////////////////////////////////////////////////////////////////////
// Overview
// Generate PWM signal
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module pwm
#(
  parameter CLK_FREQ = 100000000,
  parameter PWM_FREQ = 20000,
  parameter WL = $clog2(CLK_FREQ/PWM_FREQ+1)
)
(
  input  wire           reset,
  input  wire           clk,
  
  input  wire  [WL-1:0] i_duty_cycle,
  output logic          o_pwm
);
  
  localparam unsigned PWM_MAX_CNT = int'(CLK_FREQ/PWM_FREQ);
  logic [WL-1:0] pwm_cnt;
  
  always_ff @( posedge clk ) begin : pwm_cnt_proc
    if (reset) begin
      pwm_cnt <= '0;
      o_pwm   <= 1'b0;
    end else begin
      
      if(pwm_cnt < PWM_MAX_CNT[WL-1:0]) begin
          pwm_cnt <= pwm_cnt + 1;
      end else begin
          pwm_cnt <= '0;
      end
      o_pwm <= (i_duty_cycle <= pwm_cnt) ? (1'b0) : (1'b1);
    end  // rst
  end // pwm_cnt_proc
  
endmodule: pwm

`default_nettype wire
