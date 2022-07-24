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
  parameter RISCV_TEXT      = "../vexriscv_generator/VexRiscvBase/build/main.mem"
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
  
  // DC Motors PWM
  output logic m0_fwd_pwm,
  output logic m0_bwd_pwm,
  output logic m1_fwd_pwm,
  output logic m1_bwd_pwm,
  
  // Distance Sensor(s)
  output logic frnt_dst_sens_trigger,
  input  wire  frnt_dst_sens_edge,
  
  // UART
  input  wire  uart_rx,
  output logic uart_tx
);
  // ------------------------------------------------------------
  localparam RISCV_WL_BYTES = RISCV_WL/8;
  localparam RISCV_PLS_WL = $clog2(RISCV_WL_BYTES-1);  // VexRiscv dBus_cmd_payload_size (byte mem access)
  
  // ------------------------------------------------------------
  // IO parameters
`ifdef COCOTB_SIM
  initial begin
    $display("Setting SIM parameters...");
  end
  // Debouncers
  localparam CLICK_DEBOUNCE_MS      = 0;
  localparam LONG_PRESS_DURATION_MS = 0;
  
  // Periph.
  localparam RGB_PWM_FREQ    = CLK_FREQ/32;
  localparam UART0_BAUD_RATE = 1152000;
  localparam MOTOR_PWM_FREQ  = CLK_FREQ/100;
  
  // Distance measurement
  localparam DISTANCE_SENSOR_PING_FREQ        = 10000;
  localparam DISTANCE_SENSOR_TRIG_DURATION_US = 1;
  localparam DISTANCE_SENSOR_MAX_DISTANCE_M  = 4;
  
`else
  // Debouncers
  localparam CLICK_DEBOUNCE_MS      = 10;
  localparam LONG_PRESS_DURATION_MS = 1000;
  
  // Periph.
  localparam RGB_PWM_FREQ    = 20000;
  localparam UART0_BAUD_RATE = 115200;
  localparam MOTOR_PWM_FREQ  = 500;
  
  // Distance measurement
  localparam DISTANCE_SENSOR_PING_FREQ        = 10;
  localparam DISTANCE_SENSOR_TRIG_DURATION_US = 10;
  localparam DISTANCE_SENSOR_MAX_DISTANCE_M  = 4;
  
`endif
  
  // ------------------------------------------------------------
  // System reset
  logic do_reset;
  logic sys_reset;
  logic boot_reset;
  
  // reset system or boot
  btn_debouncer #(
    .CLK_FREQUENCY(CLK_FREQ),
    .BUTTON_INPUT_LEVEL(0),
    .CLICK_OUTPUT_LEVEL(1),
    .CLICK_DEBOUNCE_MS(CLICK_DEBOUNCE_MS),
    .PRESS_OUTPUT_LEVEL(1),
    .LONG_PRESS_DURATION_MS(LONG_PRESS_DURATION_MS)
  )
  reset_btn_debouncer_inst(
    .reset(1'b0),
    .clk(clk),
    .usr_btn(resetn),
    .click(do_reset),
    .press(),
    .long_press(boot_reset)
  );
  always_comb sys_reset = do_reset | boot_reset;
  
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
  logic io_slct_d;
  always_comb io_slct = dBus_cmd_payload_address[RISCV_WL-1];
  always_ff @( posedge clk ) begin
    io_slct_d <= io_slct;
  end
  
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
        .PRESS_OUTPUT_LEVEL(1),
        .LONG_PRESS_DURATION_MS(LONG_PRESS_DURATION_MS)
      )
      reset_btn_debouncer_inst(
        .reset(sys_reset),
        .clk(clk),
        .usr_btn(btn[i]),
        .click(),
        .press(btn_dbncd[i]),
        .long_press()
      );
    end: btn_debouncer_gen
  endgenerate
  
  // --------------------------------------------------
  // RGB LEDs PWM (to lower intensity)
  localparam PWM_DCYCLE_WL = $clog2(CLK_FREQ/RGB_PWM_FREQ+1);
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
  localparam IO_REG_SPACE = 16;
  localparam IO_SPACE_ADDR_WL = $clog2(IO_REG_SPACE-1);
  
  typedef enum  {
    DEBUG_REG           =  0,
    UART0_TX_REG        =  1,
    UART0_RX_REG        =  2,
    LEDS_REG            =  3,
    RGB0_REG            =  4,
    RGB0_DCYCLE_REG     =  5,
    RGB1_REG            =  6,
    RGB1_DCYCLE_REG     =  7,
    BUTTONS_REG         =  8,
    SWITCHES_REG        =  9,
    M0_FWD_PWM_REG      = 10,
    M0_BWD_PWM_REG      = 11,
    M1_FWD_PWM_REG      = 12,
    M1_BWD_PWM_REG      = 13,
    DST_SENSOR_RD_REG        = 14
  } io_registers;
  
  logic                io_wen;
  logic [IO_SPACE_ADDR_WL-1:0] io_addr;
  logic [RISCV_WL-1:0] io_wdata;
  logic [RISCV_WL-1:0] io_rdata;
  logic [RISCV_WL-1:0] io_regs[IO_REG_SPACE];
  
  always_comb begin
    io_wen   = dBus_cmd_payload_wr;
    io_addr  = dBus_cmd_payload_address[IO_SPACE_ADDR_WL+1:2];
    io_wdata = dBus_cmd_payload_data;
  end
  
  always_ff @( posedge clk ) begin: io_regs_update_proc
    if(sys_reset) begin
      // UART
      uart0_tx_vld <= 0;
      
      // IO regs
      io_regs <= '{default:0};
      
    end else begin
      // Capture input states
      io_regs[BUTTONS_REG]  <= {28'd0, btn_dbncd};
      io_regs[SWITCHES_REG] <= {28'd0, sw};
      
      // UART regs.
      if(uart0_rx_valid) begin
        io_regs[UART0_RX_REG] <= {1'b1, { (RISCV_WL-1-8){1'b0} }, uart0_rx_data};
      end
      
      if(uart0_tx_rdy && io_regs[UART0_TX_REG][RISCV_WL-1]) begin
        io_regs[UART0_TX_REG][RISCV_WL-1] <= 0;
        uart0_tx_vld <= 1'b1;
        uart0_tx_data <= io_regs[UART0_TX_REG][7:0];
        io_regs[UART0_TX_REG][RISCV_WL-1] <= 0;
        
      end else begin
          uart0_tx_vld <= 1'b0;
          
      end
      
      // Distance sensor
      if(frnt_valid == 1'b1) begin
        io_regs[DST_SENSOR_RD_REG] <= {1'b1, frnt_edge_ticks};
      end
      
      // IO FW access
      if(dBus_cmd_valid && io_slct) begin
        io_rdata <= (io_wen) ? (io_wdata) : (io_regs[io_addr]);
        
        if(io_wen) begin
          io_regs[io_addr] <= io_wdata;
          
        end else begin: io_regs_vl_read_update
          
          // HW op. when reading back registers
          case({ {(RISCV_WL-IO_SPACE_ADDR_WL){1'b0}}, io_addr})
            UART0_RX_REG, DST_SENSOR_RD_REG: begin
              io_regs[io_addr][31] <= 1'b0;
            end
          endcase
        end
      end
    end
  end: io_regs_update_proc
  
  // ----------------------------------------
  // LEDs
  always_comb begin: leds_comb
    leds = io_regs[LEDS_REG][3:0];
  end: leds_comb
  
  // ----------------------------------------
  // RGBs
  always_comb begin: rgb_comb
    rgb0_dcycle = io_regs[RGB0_DCYCLE_REG];
    rgb0        = io_regs[RGB0_REG][2:0] & { 3{rgb0_pwm} };
    
    rgb1_dcycle = io_regs[RGB1_DCYCLE_REG];
    rgb1        = io_regs[RGB1_REG][2:0] & { 3{rgb1_pwm} };
  end: rgb_comb
  
  // ----------------------------------------
  // UART0
  // TX port
  logic       uart0_tx_rdy;
  logic       uart0_tx_vld;
  logic [7:0] uart0_tx_data;
  logic       uart0_tx_uart;
  
  // RX port
  logic       uart0_rx_valid;
  logic [7:0] uart0_rx_data;
  logic       uart0_rx_uart;
  
  uart_lite #(
    .BAUD_RATE(UART0_BAUD_RATE),
    .CLK_FREQUENCY(CLK_FREQ),
    .DATA_BITS(8),
    .RX_SAMPLES(3)
  ) uart0_inst
  (
    .clk(clk),
    .reset(sys_reset),
    .tx_rdy(uart0_tx_rdy),
    .tx_vld(uart0_tx_vld),
    .tx_data(uart0_tx_data),
    .tx_uart(uart0_tx_uart),
    .rx_valid(uart0_rx_valid),
    .rx_data(uart0_rx_data),
    .rx_uart(uart0_rx_uart)
  );
  
  always_comb begin: uart0_comb
    // = io_regs[UART0_TX];
    uart_tx = uart0_tx_uart;
    uart0_rx_uart = uart_rx;
  end: uart0_comb
  
  // ----------------------------------------
  // DC Motors PWM
/* verilator lint_off WIDTH */
  logic [3:0] dc_motors_pwm;
  generate
    genvar inx;
    for(inx=0; inx < 4; inx = inx + 1) begin: dc_motors_pwm_gen
      pwm
      #(
        .CLK_FREQ(CLK_FREQ),
        .PWM_FREQ(MOTOR_PWM_FREQ)
      )
      pwm_dc_motor
      (
        .clk(clk),
        .reset(sys_reset),
        .i_duty_cycle(io_regs[M0_FWD_PWM_REG+inx]),
        .o_pwm(dc_motors_pwm[inx])
      );
    end
  endgenerate
/* verilator lint_on WIDTH */
  
  always_comb begin: dc_motors_pwm_comb
    m0_fwd_pwm = dc_motors_pwm[0];
    m0_bwd_pwm = dc_motors_pwm[1];
    m1_fwd_pwm = dc_motors_pwm[2];
    m1_bwd_pwm = dc_motors_pwm[3];
  end
  
  // ----------------------------------------
  // Distance Sensor Trigger
  logic                frnt_valid;
  logic [RISCV_WL-2:0] frnt_edge_ticks;
  hc_sr04_distance_sensor
  #(
    .CLK_FREQ(CLK_FREQ),
    .PING_FREQ(DISTANCE_SENSOR_PING_FREQ),
    .TRIG_DURATION_US(DISTANCE_SENSOR_TRIG_DURATION_US),
    .MAX_DISTANCE_M(DISTANCE_SENSOR_MAX_DISTANCE_M),
    .O_WL(RISCV_WL-1)
  )
  hc_sr04_distance_sensor_inst
  (
    .reset(sys_reset),
    .clk(clk),
    .sn_trigger(frnt_dst_sens_trigger),
    .sn_edge(frnt_dst_sens_edge),
    .o_valid(frnt_valid),
    .edge_ticks(frnt_edge_ticks)
  );
  
  // ----------------------------------------
  always_comb dBus_rsp_data = (io_slct_d) ? (io_rdata) : (mem_rdata);
  
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
