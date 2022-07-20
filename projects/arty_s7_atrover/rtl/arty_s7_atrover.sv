`timescale 1ns/1ps

module arty_s7_atrover (
  input               reset,
  input               clk,
  
  // IO
  input  wire  [3:0] sw,  // Switches
  input  wire  [3:0] btn, // buttons
  output logic [3:0] led,
  output logic [2:0] rgb0,
  output logic [2:0] rgb1,
  
  // Peripherals
  input  wire  uart_rx,
  output logic uart_tx
)
  
  // VexRiscv instantiation
  logic              iBus_cmd_valid;
  logic              iBus_cmd_ready;
  logic     [31:0]   iBus_cmd_payload_pc;
  logic              iBus_rsp_valid;
  logic              iBus_rsp_payload_error;
  logic     [31:0]   iBus_rsp_payload_inst;
  logic              dBus_cmd_valid;
  logic              dBus_cmd_ready;
  logic              dBus_cmd_payload_wr;
  logic     [31:0]   dBus_cmd_payload_address;
  logic     [31:0]   dBus_cmd_payload_data;
  logic     [1:0]    dBus_cmd_payload_size;
  logic              dBus_rsp_ready;
  logic              dBus_rsp_error;
  logic     [31:0]   dBus_rsp_data;
  logic              timerInterrupt;
  logic              externalInterrupt;
  logic              softwareInterrupt;
  
  VexRiscvBase VexRiscvBase_inst (
    .clk                      (clk                                             ), //i
    .reset                    (reset                                           ), //i
    .iBus_cmd_valid           (iBus_cmd_valid                ), //o
    .iBus_cmd_ready           (iBus_cmd_ready                                  ), //i
    .iBus_cmd_payload_pc      (iBus_cmd_payload_pc[31:0]     ), //o
    .iBus_rsp_valid           (iBus_rsp_valid                                  ), //i
    .iBus_rsp_payload_error   (iBus_rsp_payload_error                          ), //i
    .iBus_rsp_payload_inst    (iBus_rsp_payload_inst[31:0]                     ), //i
    .dBus_cmd_valid           (dBus_cmd_valid                ), //o
    .dBus_cmd_ready           (dBus_cmd_ready                                  ), //i
    .dBus_cmd_payload_wr      (dBus_cmd_payload_wr           ), //o
    .dBus_cmd_payload_address (dBus_cmd_payload_address[31:0]), //o
    .dBus_cmd_payload_data    (dBus_cmd_payload_data[31:0]   ), //o
    .dBus_cmd_payload_size    (dBus_cmd_payload_size[1:0]    ), //o
    .dBus_rsp_ready           (dBus_rsp_ready                                  ), //i
    .dBus_rsp_error           (dBus_rsp_error                                  ), //i
    .dBus_rsp_data            (dBus_rsp_data[31:0]                             ), //i
    .timerInterrupt           (timerInterrupt                                  ), //i
    .externalInterrupt        (externalInterrupt                               ), //i
    .softwareInterrupt        (softwareInterrupt                               )  //i
  );

endmodule
