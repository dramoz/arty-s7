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
  
  vexriscv_ram #(
    parameter RAM_DEPTH = 16384
  )
  vexriscv_ram_inst
  (
    .reset(reset),
    .clk(clk),
    .ibus_en(1'b1),
    .ibus_we(1'b0),
    .ibus_addr(iBus_cmd_payload_pc),
    .ibus_din('0),
    .ibus_regce(1'b0),
    .ibus_dout(iBus_rsp_payload_inst),
    .dbus_en(1'b1),
    .dbus_we(dbus_we),
    .dbus_addr(dBus_cmd_payload_address),
    .dbus_din(dBus_cmd_payload_data),
    .dbus_regce(1'b0),
    .dbus_dout(dBus_rsp_data)
  );
  
  assign iBus_cmd_ready = 1'b1;
  assign dBus_cmd_ready = 1'b1;
  always_ff(@posedge clk) begin
    iBus_rsp_valid <= iBus_cmd_valid;
    dBus_rsp_valid <= dBus_cmd_valid;
  end
  
  assign iBus_rsp_payload_error = 1'b0;
  
  assign timerInterrupt    = 1'b0;
  assign externalInterrupt = 1'b0;
  assign softwareInterrupt = 1'b0;
  
  VexRiscvBase VexRiscvBase_inst (
    .clk                      (clk),
    .reset                    (reset),
    .iBus_cmd_valid           (iBus_cmd_valid),
    .iBus_cmd_ready           (iBus_cmd_ready),
    .iBus_cmd_payload_pc      (iBus_cmd_payload_pc),
    .iBus_rsp_valid           (iBus_rsp_valid),
    .iBus_rsp_payload_error   (iBus_rsp_payload_error),
    .iBus_rsp_payload_inst    (iBus_rsp_payload_inst),
    .dBus_cmd_valid           (dBus_cmd_valid),
    .dBus_cmd_ready           (dBus_cmd_ready),
    .dBus_cmd_payload_wr      (dBus_cmd_payload_wr),
    .dBus_cmd_payload_address (dBus_cmd_payload_address),
    .dBus_cmd_payload_data    (dBus_cmd_payload_data),
    .dBus_cmd_payload_size    (dBus_cmd_payload_size),
    .dBus_rsp_ready           (dBus_rsp_ready),
    .dBus_rsp_error           (dBus_rsp_error),
    .dBus_rsp_data            (dBus_rsp_data),
    .timerInterrupt           (timerInterrupt),
    .externalInterrupt        (externalInterrupt),
    .softwareInterrupt        (softwareInterrupt)
  );
  
endmodule
