# Entity: vexriscv_ram 

- **File**: vexriscv_ram.v
## Diagram

![Diagram](vexriscv_ram.svg "Diagram")
## Generics

| Generic name | Type | Value | Description |
| ------------ | ---- | ----- | ----------- |
| NB_COL       |      | 4     |             |
| COL_WIDTH    |      | 8     |             |
| RAM_DEPTH    |      | 1024  |             |
| INIT_FILE    |      | ""    |             |
## Ports

| Port name | Direction | Type                            | Description |
| --------- | --------- | ------------------------------- | ----------- |
| clk       | input     | wire                            |             |
| ibus_en   | input     | wire                            |             |
| ibus_we   | input     | wire  [NB_COL-1:0]              |             |
| ibus_addr | input     | wire  [$clog2(RAM_DEPTH-1)-1:0] |             |
| ibus_din  | input     | wire  [(NB_COL*COL_WIDTH)-1:0]  |             |
| ibus_dout | output    | wire [(NB_COL*COL_WIDTH)-1:0]   |             |
| dbus_en   | input     | wire                            |             |
| dbus_we   | input     | wire  [NB_COL-1:0]              |             |
| dbus_addr | input     | wire  [$clog2(RAM_DEPTH-1)-1:0] |             |
| dbus_din  | input     | wire  [(NB_COL*COL_WIDTH)-1:0]  |             |
| dbus_dout | output    | wire [(NB_COL*COL_WIDTH)-1:0]   |             |
## Signals

| Name          | Type                         | Description |
| ------------- | ---------------------------- | ----------- |
| vexriscv_mem  | reg [(NB_COL*COL_WIDTH)-1:0] |             |
| ibus_ram_data | reg [(NB_COL*COL_WIDTH)-1:0] |             |
| dbus_ram_data | reg [(NB_COL*COL_WIDTH)-1:0] |             |
