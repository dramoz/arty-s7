# Entity: arty_s7_atrover 

- **File**: arty_s7_atrover.sv
## Diagram

![Diagram](arty_s7_atrover.svg "Diagram")
## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| reset     | input     |             |             |
| clk       | input     |             |             |
| sw        | input     | wire  [3:0] |             |
| btn       | input     | wire  [3:0] |             |
| led       | output    | [3:0]       |             |
| rgb0      | output    | [2:0]       |             |
| rgb1      | output    | [2:0]       |             |
| uart_rx   | input     | wire        |             |
| uart_tx   | output    |             |             |
## Signals

| Name                     | Type             | Description |
| ------------------------ | ---------------- | ----------- |
| iBus_cmd_ready           | logic            |             |
| iBus_cmd_payload_pc      | logic     [31:0] |             |
| iBus_rsp_valid           | logic            |             |
| iBus_rsp_payload_error   | logic            |             |
| iBus_rsp_payload_inst    | logic     [31:0] |             |
| dBus_cmd_valid           | logic            |             |
| dBus_cmd_ready           | logic            |             |
| dBus_cmd_payload_wr      | logic            |             |
| dBus_cmd_payload_address | logic     [31:0] |             |
| dBus_cmd_payload_data    | logic     [31:0] |             |
| dBus_cmd_payload_size    | logic     [1:0]  |             |
| dBus_rsp_ready           | logic            |             |
| dBus_rsp_error           | logic            |             |
| dBus_rsp_data            | logic     [31:0] |             |
| timerInterrupt           | logic            |             |
| externalInterrupt        | logic            |             |
| softwareInterrupt        | logic            |             |
## Instantiations

- VexRiscvBase_inst: VexRiscvBase
