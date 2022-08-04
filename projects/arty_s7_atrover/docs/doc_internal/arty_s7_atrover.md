# Entity: arty_s7_atrover 

- **File**: arty_s7_atrover.sv
## Diagram

![Diagram](arty_s7_atrover.svg "Diagram")
## Generics

| Generic name    | Type | Value                                               | Description |
| --------------- | ---- | --------------------------------------------------- | ----------- |
| CLK_FREQ        |      | 100000000                                           |             |
| RISCV_RAM_DEPTH |      | 8192                                                |             |
| RISCV_WL        |      | 32                                                  |             |
| RISCV_TEXT      |      | "../vexriscv_generator/VexRiscvBase/build/main.mem" |             |
## Ports

| Port name             | Direction | Type        | Description |
| --------------------- | --------- | ----------- | ----------- |
| resetn                | input     | wire        |             |
| clk                   | input     | wire        |             |
| sw                    | input     | wire  [3:0] |             |
| btn                   | input     | wire  [3:0] |             |
| leds                  | output    | [3:0]       |             |
| rgb0                  | output    | [2:0]       |             |
| rgb1                  | output    | [2:0]       |             |
| m0_fwd_pwm            | output    |             |             |
| m0_bwd_pwm            | output    |             |             |
| m1_fwd_pwm            | output    |             |             |
| m1_bwd_pwm            | output    |             |             |
| frnt_dst_sens_trigger | output    |             |             |
| frnt_dst_sens_edge    | input     | wire        |             |
| uart_rx               | input     | wire        |             |
| uart_tx               | output    |             |             |
## Signals

| Name                     | Type                          | Description |
| ------------------------ | ----------------------------- | ----------- |
| do_reset                 | logic                         |             |
| sys_reset                | logic                         |             |
| boot_reset               | logic                         |             |
| iBus_cmd_valid           | logic                         |             |
| iBus_cmd_ready           | logic                         |             |
| iBus_cmd_payload_pc      | logic [RISCV_WL-1:0]          |             |
| iBus_rsp_valid           | logic                         |             |
| iBus_rsp_payload_error   | logic                         |             |
| iBus_rsp_payload_inst    | logic [RISCV_WL-1:0]          |             |
| dBus_cmd_valid           | logic                         |             |
| dBus_cmd_ready           | logic                         |             |
| dBus_cmd_payload_wr      | logic                         |             |
| dBus_cmd_payload_address | logic [RISCV_WL-1:0]          |             |
| dBus_cmd_payload_data    | logic [RISCV_WL-1:0]          |             |
| dBus_cmd_payload_size    | logic [RISCV_PLS_WL-1:0]      |             |
| dBus_rsp_ready           | logic                         |             |
| dBus_rsp_error           | logic                         |             |
| dBus_rsp_data            | logic [RISCV_WL-1:0]          |             |
| timerInterrupt           | logic                         |             |
| externalInterrupt        | logic                         |             |
| softwareInterrupt        | logic                         |             |
| io_slct                  | logic                         |             |
| io_slct_d                | logic                         |             |
| ibus_addr                | logic [RISCV_RAM_ADDR_WL-1:0] |             |
| byte_slct                | logic [RISCV_WL_BYTES-1:0]    |             |
| dbus_we                  | logic [RISCV_WL_BYTES-1:0]    |             |
| dbus_addr                | logic [RISCV_RAM_ADDR_WL-1:0] |             |
| mem_rdata                | logic [RISCV_WL-1:0]          |             |
| mem_wdata                | logic [RISCV_WL-1:0]          |             |
| btn_dbncd                | logic [3:0]                   |             |
| rgb0_dcycle              | logic [RISCV_WL-1:0]          |             |
| rgb0_pwm                 | logic                         |             |
| rgb1_dcycle              | logic [RISCV_WL-1:0]          |             |
| rgb1_pwm                 | logic                         |             |
| io_wen                   | logic                         |             |
| io_addr                  | logic [IO_SPACE_ADDR_WL-1:0]  |             |
| io_wdata                 | logic [RISCV_WL-1:0]          |             |
| io_rdata                 | logic [RISCV_WL-1:0]          |             |
| io_regs                  | logic [RISCV_WL-1:0]          |             |
| uart0_tx_rdy             | logic                         |             |
| uart0_tx_vld             | logic                         |             |
| uart0_tx_data            | logic [7:0]                   |             |
| uart0_tx_uart            | logic                         |             |
| uart0_rx_valid           | logic                         |             |
| uart0_rx_data            | logic [7:0]                   |             |
| uart0_rx_uart            | logic                         |             |
| dc_motors_pwm            | logic [3:0]                   |             |
| frnt_valid               | logic                         |             |
| frnt_edge_ticks          | logic [RISCV_WL-2:0]          |             |
## Constants

| Name                             | Type | Value                           | Description |
| -------------------------------- | ---- | ------------------------------- | ----------- |
| RISCV_WL_BYTES                   |      | RISCV_WL/8                      |             |
| RISCV_PLS_WL                     |      | $clog2(RISCV_WL_BYTES-1)        |             |
| CLICK_DEBOUNCE_MS                |      | 0                               |             |
| LONG_PRESS_DURATION_MS           |      | 0                               |             |
| RGB_PWM_FREQ                     |      | CLK_FREQ/32                     |             |
| UART0_BAUD_RATE                  |      | 1152000                         |             |
| MOTOR_PWM_FREQ                   |      | CLK_FREQ/100                    |             |
| DISTANCE_SENSOR_PING_FREQ        |      | 10000                           |             |
| DISTANCE_SENSOR_TRIG_DURATION_US |      | 1                               |             |
| DISTANCE_SENSOR_MAX_DISTANCE_M   |      | 4                               |             |
| CLICK_DEBOUNCE_MS                |      | 10                              |             |
| LONG_PRESS_DURATION_MS           |      | 1000                            |             |
| RGB_PWM_FREQ                     |      | 20000                           |             |
| UART0_BAUD_RATE                  |      | 115200                          |             |
| MOTOR_PWM_FREQ                   |      | 500                             |             |
| DISTANCE_SENSOR_PING_FREQ        |      | 10                              |             |
| DISTANCE_SENSOR_TRIG_DURATION_US |      | 10                              |             |
| DISTANCE_SENSOR_MAX_DISTANCE_M   |      | 4                               |             |
| RISCV_RAM_ADDR_WL                |      | $clog2(RISCV_RAM_DEPTH-1)       |             |
| PWM_DCYCLE_WL                    |      | $clog2(CLK_FREQ/RGB_PWM_FREQ+1) |             |
| IO_REG_SPACE                     |      | 16                              |             |
| IO_SPACE_ADDR_WL                 |      | $clog2(IO_REG_SPACE-1)          |             |
## Types

| Name         | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | Description |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| io_registers | enum  {<br><span style="padding-left:20px">     DEBUG_REG           =  0,<br><span style="padding-left:20px">     UART0_TX_REG        =  1,<br><span style="padding-left:20px">     UART0_RX_REG        =  2,<br><span style="padding-left:20px">     LEDS_REG            =  3,<br><span style="padding-left:20px">     RGB0_REG            =  4,<br><span style="padding-left:20px">     RGB0_DCYCLE_REG     =  5,<br><span style="padding-left:20px">     RGB1_REG            =  6,<br><span style="padding-left:20px">     RGB1_DCYCLE_REG     =  7,<br><span style="padding-left:20px">     BUTTONS_REG         =  8,<br><span style="padding-left:20px">     SWITCHES_REG        =  9,<br><span style="padding-left:20px">     M0_FWD_PWM_REG      = 10,<br><span style="padding-left:20px">     M0_BWD_PWM_REG      = 11,<br><span style="padding-left:20px">     M1_FWD_PWM_REG      = 12,<br><span style="padding-left:20px">     M1_BWD_PWM_REG      = 13,<br><span style="padding-left:20px">     DST_SENSOR_RD_REG        = 14   } |             |
## Processes
- unnamed: (  )
  - **Type:** always_comb
- unnamed: ( @( posedge clk ) )
  - **Type:** always_ff
- unnamed: (  )
  - **Type:** always_comb
- unnamed: ( @( posedge clk ) )
  - **Type:** always_ff
- unnamed: (  )
  - **Type:** always_comb
- unnamed: (  )
  - **Type:** always_comb
- dbus_wr_slct: (  )
  - **Type:** always_comb
- unnamed: (  )
  - **Type:** always_comb
- io_regs_update_proc: ( @( posedge clk ) )
  - **Type:** always_ff
- leds_comb: (  )
  - **Type:** always_comb
- rgb_comb: (  )
  - **Type:** always_comb
- uart0_comb: (  )
  - **Type:** always_comb
- dc_motors_pwm_comb: (  )
  - **Type:** always_comb
- unnamed: (  )
  - **Type:** always_comb
## Instantiations

- reset_btn_debouncer_inst: btn_debouncer
- vexriscv_ram_inst: vexriscv_ram
- uart0_inst: uart_lite
- hc_sr04_distance_sensor_inst: hc_sr04_distance_sensor
- VexRiscvBase_inst: VexRiscvBase
