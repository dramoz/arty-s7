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
  parameter WL = $clog2(CLK_FREQ/PWM_FREQ)
)
(
  input  wire           rst,  // reset, active low (top right, red button)
  input  wire           clk,  // 12 MHz, ~83.33ns
  
  input  wire  [WL-1:0] i_duty_cycle,
  output logic          o_pwm
);

localparam logic [WL-1:0] PWM_MAX_CNT = $ceil(CLK_FREQ/PWM_FREQ);
logic [WL-1:0] pwm_cnt = '0;

always_ff @( posedge clk ) begin : pwm_cnt_proc
  if (!rst) begin
    pwm_cnt  <= '0;
  end else begin
    
    if(pwm_cnt < PWM_MAX_CNT) begin
        pwm_cnt <= pwm_cnt + 1;
    end else begin
        pwm_cnt <= '0;
    end
  end  // rst
  
end // pwm_cnt_proc

assign o_pwm = (pwm_cnt < i_duty_cycle) ? (1'b0) : (1'b1);

endmodule: pwm

`default_nettype wire
