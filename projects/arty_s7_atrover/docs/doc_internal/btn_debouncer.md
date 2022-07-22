# Entity: btn_debouncer 

- **File**: btn_debouncer.sv
## Diagram

![Diagram](btn_debouncer.svg "Diagram")
## Generics

| Generic name           | Type | Value     | Description |
| ---------------------- | ---- | --------- | ----------- |
| CLK_FREQUENCY          |      | 100000000 |             |
| BUTTON_INPUT_LEVEL     |      | 1         |             |
| CLICK_OUTPUT_LEVEL     |      | 1         |             |
| CLICK_DEBOUNCE_MS      |      | 10        |             |
| PRESS_OUTPUT_LEVEL     |      | 1         |             |
| LONG_PRESS_DURATION_MS |      | 1000      |             |
## Ports

| Port name  | Direction | Type | Description |
| ---------- | --------- | ---- | ----------- |
| reset      | input     | wire |             |
| clk        | input     | wire |             |
| usr_btn    | input     | wire |             |
| click      | output    |      |             |
| press      | output    |      |             |
| long_press | output    |      |             |
## Signals

| Name         | Type                    | Description |
| ------------ | ----------------------- | ----------- |
| xor_path     | logic [1:0]             |             |
| boot_counter | logic [BOOT_CNT_WL-1:0] |             |
## Constants

| Name            | Type | Value                   | Description |
| --------------- | ---- | ----------------------- | ----------- |
| CLICK_CLKS      |      | (1)                     |             |
| LONG_PRESS_CLKS |      | (10*CLICK_CLKS)         |             |
| BOOT_CNT_WL     |      | $clog2(LONG_PRESS_CLKS) |             |
## Processes
- unnamed: ( @( posedge clk ) )
  - **Type:** always_ff
