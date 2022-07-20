///////////////////////////////////////////////////////////////////////////////
// File: arty_s7_atrover.sv
// Copyright (c) 2022. Danilo Ramos
// All rights reserved.
// This license message must appear in all versions of this code including
// modified versions.
////////////////////////////////////////////////////////////////////////////////
// Overview
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none
//`include "cpu_layout.v"

module arty_s7_atrover #(
  parameter CLK_FREQ        = 100000000,
  parameter RISCV_RAM_DEPTH = 8192,
  parameter RISCV_WL        = 32,
  parameter RISCV_TEXT      = "../vexriscv_generator/VexRiscvBase/build/main.hex"
)
(
  input wire resetn,
  input wire clk,
  
  // IO
  input  wire  [3:0] sw,  // Switches
  input  wire  [3:0] btn, // buttons
  output logic [3:0] leds,
  output logic [2:0] rgb0,
  output logic [2:0] rgb1,
  
  // Peripherals
  input  wire  uart_rx,
  output logic uart_tx
);
  // ------------------------------------------------------------
  localparam RISCV_WL_BYTES = RISCV_WL/8;
  localparam RISCV_PLS_WL = $clog2(RISCV_WL_BYTES-1);  // VexRiscv dBus_cmd_payload_size (byte mem access)
  
  // ------------------------------------------------------------
  // Button debouncing parameters
  localparam CLICK_DEBOUNCE_MS = 10;
  localparam LONG_PRESS_DURATION_MS = 1000;
  // ------------------------------------------------------------
  // System reset
  logic sys_reset;
  logic boot_reset;
  
  // reset system or boot
  btn_debouncer #(
    .CLK_FREQUENCY(CLK_FREQ),
    .BUTTON_INPUT_LEVEL(0),
    .CLICK_OUTPUT_LEVEL(1),
    .CLICK_DEBOUNCE_MS(CLICK_DEBOUNCE_MS),
    .LONG_PRESS_OUTPUT_LEVEL(1),
    .LONG_PRESS_DURATION_MS(LONG_PRESS_DURATION_MS)
  )
  reset_btn_debouncer_inst(
    .reset(1'b0),
    .clk(clk),
    .usr_btn(resetn),
    .click(sys_reset),
    .long_press(boot_reset)
  );
  // --------------------------------------------------
  localparam RISCV_RAM_ADDR_WL = $clog2(RISCV_RAM_DEPTH-1);
  
  // ------------------------------------------------------------
  // VexRiscv IO ports signals
  logic                iBus_cmd_valid;
  logic                iBus_cmd_ready;
  logic [RISCV_WL-1:0] iBus_cmd_payload_pc;
  logic                iBus_rsp_valid;
  logic                iBus_rsp_payload_error;
  logic [RISCV_WL-1:0] iBus_rsp_payload_inst;
  
  logic                    dBus_cmd_valid;
  logic                    dBus_cmd_ready;
  logic                    dBus_cmd_payload_wr;
  logic [RISCV_WL-1:0]     dBus_cmd_payload_address;
  logic [RISCV_WL-1:0]     dBus_cmd_payload_data;
  logic [RISCV_PLS_WL-1:0] dBus_cmd_payload_size;
  
  logic                dBus_rsp_ready;
  logic                dBus_rsp_error;
  logic [RISCV_WL-1:0] dBus_rsp_data;
  
  logic                timerInterrupt;
  logic                externalInterrupt;
  logic                softwareInterrupt;
  
  // --------------------------------------------------
  // VexRiscv Memory/Pheriperals access logic
  assign iBus_cmd_ready = 1'b1;
  assign dBus_cmd_ready = 1'b1;
  always_ff @( posedge clk ) begin
    iBus_rsp_valid <= iBus_cmd_valid;
    iBus_rsp_payload_error <= (iBus_cmd_payload_pc[RISCV_WL-1:RISCV_RAM_ADDR_WL] != '0);
    
    dBus_rsp_ready <= dBus_cmd_valid && !dBus_cmd_payload_wr;
    dBus_rsp_error <= (dBus_cmd_payload_address[RISCV_WL-1-1:RISCV_RAM_ADDR_WL] != 0);
  end
  
  // ----------------------------------------
  // IO or Mem access?
  logic io_slct;
  always_comb io_slct = dBus_cmd_payload_address[RISCV_WL-1];
  
  // ----------------------------------------
  // Translate byte address to double-word address
  // Write select
  logic [RISCV_RAM_ADDR_WL-1:0] ibus_addr;
  always_comb ibus_addr = iBus_cmd_payload_pc[RISCV_RAM_ADDR_WL+1:2];
  
  logic [RISCV_WL_BYTES-1:0]    byte_slct;
  logic [RISCV_WL_BYTES-1:0]    dbus_we;
  logic [RISCV_RAM_ADDR_WL-1:0] dbus_addr;
  
  // Read capture
  logic [RISCV_WL-1:0] mem_rdata;
  logic [RISCV_WL-1:0] mem_wdata;
  always_comb mem_wdata = dBus_cmd_payload_data;
  
  always_comb begin: dbus_wr_slct
    case (dBus_cmd_payload_size)
      2'b00:   byte_slct = 4'b0001 << dBus_cmd_payload_address[1:0];
      2'b01:   byte_slct = 4'b0011 << dBus_cmd_payload_address[1:0];
      default: byte_slct = 4'b1111;
    endcase
    dbus_addr = dBus_cmd_payload_address[RISCV_RAM_ADDR_WL+1:2];
    if(io_slct) begin
      dbus_we = '0;
    end else begin
      dbus_we = { 4{dBus_cmd_valid && dBus_cmd_payload_wr} } & byte_slct;
    end
  end: dbus_wr_slct
  
  vexriscv_ram #(
    .NB_COL(RISCV_WL_BYTES),
    .RAM_DEPTH(RISCV_RAM_DEPTH),
    .INIT_FILE(RISCV_TEXT)
  )
  vexriscv_ram_inst
  (
    .clk(clk),
    .ibus_en(1'b1),
    .ibus_we('0),
    .ibus_addr(ibus_addr),
    .ibus_din('0),
    .ibus_dout(iBus_rsp_payload_inst),
    .dbus_en(1'b1),
    .dbus_we(dbus_we),
    .dbus_addr(dbus_addr),
    .dbus_din(mem_wdata),
    .dbus_dout(mem_rdata)
  );
  
  // --------------------------------------------------
  // IO access control
  
  // --------------------------------------------------
  // Buttons debouncers
  logic [3:0] btn_dbncd;
  generate
    genvar i;
    for(i=0; i < 4; i=i+1) begin: btn_debouncer_gen
      btn_debouncer #(
        .CLK_FREQUENCY(CLK_FREQ),
        .BUTTON_INPUT_LEVEL(1),
        .CLICK_OUTPUT_LEVEL(1),
        .CLICK_DEBOUNCE_MS(CLICK_DEBOUNCE_MS),
        .LONG_PRESS_OUTPUT_LEVEL(1),
        .LONG_PRESS_DURATION_MS(LONG_PRESS_DURATION_MS)
      )
      reset_btn_debouncer_inst(
        .reset(sys_reset),
        .clk(clk),
        .usr_btn(btn[i]),
        .click(btn_dbncd[i]),
        .long_press()
      );
    end: btn_debouncer_gen
  endgenerate
  
  // --------------------------------------------------
  // RGB LEDs PWM (to lower intensity)
  localparam RGB_PWM_FREQ  = 20000;
  localparam PWM_DCYCLE_WL = $clog2(CLK_FREQ/RGB_PWM_FREQ);
  logic [RISCV_WL-1:0] rgb0_dcycle;
  logic                rgb0_pwm;
  pwm
  #(
    .CLK_FREQ(CLK_FREQ),
    .PWM_FREQ(RGB_PWM_FREQ)
  )
  rgb0_pwm_inst
  (
    .clk(clk),
    .reset(sys_reset),
    .i_duty_cycle(rgb0_dcycle[PWM_DCYCLE_WL-1:0]),
    .o_pwm(rgb0_pwm)
  );
  
  logic [RISCV_WL-1:0] rgb1_dcycle;
  logic                rgb1_pwm;
  pwm
  #(
    .CLK_FREQ(CLK_FREQ),
    .PWM_FREQ(RGB_PWM_FREQ)
  )
  rgb1_pwm_inst
  (
    .clk(clk),
    .reset(sys_reset),
    .i_duty_cycle(rgb1_dcycle[PWM_DCYCLE_WL-1:0]),
    .o_pwm(rgb1_pwm)
  );
  // --------------------------------------------------
  // IO/Peripherals access
  typedef enum  {
    DEBUG_REG            = 0,
    UART0_TX_REG         = 1,
    UART0_RX_REG         = 2,
    LEDS_REG             = 3,
    RGB0_REG             = 4,
    RGB0_DCYCLE_REG      = 5,
    RGB1_REG             = 6,
    RGB1_DCYCLE_REG      = 7,
    BUTTONS_REG          = 8,
    SWITCHES_REG         = 9
  } io_registers;
  
  localparam IO_REG_SPACE = 16;
  localparam IO_SPACE_ADDR_WL = $clog2(IO_REG_SPACE-1);
  
  logic                io_wen;
  logic [IO_SPACE_ADDR_WL-1:0] io_addr;
  logic [RISCV_WL-1:0] io_wdata;
  logic [RISCV_WL-1:0] io_rdata;
  logic [RISCV_WL-1:0] io_regs[IO_REG_SPACE];
  
  always_comb begin
    io_wen   = dBus_cmd_payload_wr;
    io_addr  = dBus_cmd_payload_address[IO_SPACE_ADDR_WL+1:2];
    io_wdata = dBus_cmd_payload_data;
    io_rdata = (io_wen) ? (io_wdata) : (io_regs[io_addr]);
  end
  
  always_ff @( posedge clk ) begin
    if(sys_reset) begin
      io_regs <= '{default:0};
      
    end else begin
      if(dBus_cmd_valid && io_slct) begin
        if(io_wen) begin
          io_regs[io_addr] <= io_wdata;
          
        end else begin: io_regs_vl_read_update
          io_regs[UART0_RX_REG] <= '0;
          io_regs[BUTTONS_REG]  <= {28'd0, btn_dbncd};
          io_regs[SWITCHES_REG] <= {28'd0, sw};
          
        end
      end
    end
  end
  
  // LEDs
  always_comb begin: leds_comb
    leds = io_regs[LEDS_REG][3:0];
  end: leds_comb
  
  // RGBs
  always_comb begin: rgb_comb
    rgb0_dcycle = io_regs[RGB0_DCYCLE_REG];
    rgb0        = io_regs[RGB0_REG][2:0] & { 3{rgb0_pwm} };
    
    rgb1_dcycle = io_regs[RGB1_DCYCLE_REG];
    rgb1        = io_regs[RGB1_REG][2:0] & { 3{rgb1_pwm} };
  end: rgb_comb
  
  // UART0
  always_comb begin: uart0_comb
    // = io_regs[UART0_TX];
    uart_tx = 1'b1;
  end: uart0_comb
  
  always_comb dBus_rsp_data = (io_slct) ? (io_rdata) : (mem_rdata);
  // --------------------------------------------------
  // Interrupts handlers
  assign timerInterrupt    = 1'b0;
  assign externalInterrupt = 1'b0; // |btn_dbncd;
  assign softwareInterrupt = 1'b0;
  
  // --------------------------------------------------
  VexRiscvBase VexRiscvBase_inst (
    .clk                      (clk),
    .reset                    (boot_reset),
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
  // --------------------------------------------------
  
endmodule

`default_nettype wire
