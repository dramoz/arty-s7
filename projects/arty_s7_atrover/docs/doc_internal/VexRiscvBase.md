# Entity: VexRiscvBase 

- **File**: VexRiscvBase.v
## Diagram

![Diagram](VexRiscvBase.svg "Diagram")
## Ports

| Port name                | Direction | Type   | Description |
| ------------------------ | --------- | ------ | ----------- |
| iBus_cmd_valid           | output    |        |             |
| iBus_cmd_ready           | input     |        |             |
| iBus_cmd_payload_pc      | output    | [31:0] |             |
| iBus_rsp_valid           | input     |        |             |
| iBus_rsp_payload_error   | input     |        |             |
| iBus_rsp_payload_inst    | input     | [31:0] |             |
| dBus_cmd_valid           | output    |        |             |
| dBus_cmd_ready           | input     |        |             |
| dBus_cmd_payload_wr      | output    |        |             |
| dBus_cmd_payload_address | output    | [31:0] |             |
| dBus_cmd_payload_data    | output    | [31:0] |             |
| dBus_cmd_payload_size    | output    | [1:0]  |             |
| dBus_rsp_ready           | input     |        |             |
| dBus_rsp_error           | input     |        |             |
| dBus_rsp_data            | input     | [31:0] |             |
| timerInterrupt           | input     |        |             |
| externalInterrupt        | input     |        |             |
| softwareInterrupt        | input     |        |             |
| clk                      | input     |        |             |
| reset                    | input     |        |             |
## Signals

| Name                         | Type        | Description |
| ---------------------------- | ----------- | ----------- |
| cpu_iBus_cmd_valid           | wire        |             |
| cpu_iBus_cmd_payload_pc      | wire [31:0] |             |
| cpu_dBus_cmd_valid           | wire        |             |
| cpu_dBus_cmd_payload_wr      | wire        |             |
| cpu_dBus_cmd_payload_address | wire [31:0] |             |
| cpu_dBus_cmd_payload_data    | wire [31:0] |             |
| cpu_dBus_cmd_payload_size    | wire [1:0]  |             |
## Instantiations

- cpu: VexRiscv
