/*
BSD Zero Clause License
Copyright (c) 2021 Danilo Ramos
*/

/*
Module to give multiple functionality to a user input (button) by different press/hold actions
- quick press: send system reset
- press and hold: send long_press
*/

`default_nettype none
module btn_debouncer #(
  parameter CLK_FREQUENCY = 100000000,
  parameter BUTTON_INPUT_LEVEL = 1,
  parameter CLICK_OUTPUT_LEVEL = 1,
  parameter CLICK_DEBOUNCE_MS = 10,
  parameter LONG_PRESS_OUTPUT_LEVEL = 1,
  parameter LONG_PRESS_DURATION_MS = 1000
)
(
  input wire reset,
  input wire clk,
  input wire usr_btn,
  output logic click,
  output logic long_press
);
  // Reset logic
  logic [1:0] xor_path;
  localparam SYS_CLKS = $rtoi($ceil(CLK_FREQUENCY/1000*CLICK_DEBOUNCE_MS));
  localparam BOOT_CLKS = $rtoi($ceil(CLK_FREQUENCY/1000*LONG_PRESS_DURATION_MS));
  localparam BOOT_CNT_WL = $clog2(BOOT_CLKS);
  logic [BOOT_CNT_WL:0] boot_counter = '0;
  
  // Send proper rst
  assign click = (boot_counter==SYS_CLKS[0+:BOOT_CNT_WL+1]) ? (CLICK_OUTPUT_LEVEL) : (~CLICK_OUTPUT_LEVEL);
  assign long_press = (boot_counter>=BOOT_CLKS[0+:BOOT_CNT_WL+1]) ? (LONG_PRESS_OUTPUT_LEVEL):(~LONG_PRESS_OUTPUT_LEVEL);
  
  always_ff @( posedge clk ) begin
    if(reset) begin
      xor_path     <= '0;
      boot_counter <= '0;
      
    end else begin
      xor_path <= {xor_path[0], usr_btn};
      if(^xor_path) begin
        boot_counter <= '0;
        end else begin
          if(xor_path[1]==BUTTON_INPUT_LEVEL) begin
            if(boot_counter <= BOOT_CLKS[0+:BOOT_CNT_WL+1]) begin
              boot_counter <= boot_counter + 1;
            end else begin
          end
        end else begin
          boot_counter <= '0;
        end
      end
    end
  end
  
endmodule: btn_debouncer

`default_nettype wire
