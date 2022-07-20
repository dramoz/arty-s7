# Entity: pwm 

- **File**: pwm.sv
## Diagram

![Diagram](pwm.svg "Diagram")
## Generics

| Generic name | Type | Value                     | Description |
| ------------ | ---- | ------------------------- | ----------- |
| CLK_FREQ     |      | 100000000                 |             |
| PWM_FREQ     |      | 20000                     |             |
| WL           |      | $clog2(CLK_FREQ/PWM_FREQ) |             |
## Ports

| Port name    | Direction | Type           | Description |
| ------------ | --------- | -------------- | ----------- |
| reset        | input     | wire           |             |
| clk          | input     | wire           |             |
| i_duty_cycle | input     | wire  [WL-1:0] |             |
| o_pwm        | output    |                |             |
## Signals

| Name    | Type           | Description |
| ------- | -------------- | ----------- |
| pwm_cnt | logic [WL-1:0] |             |
## Constants

| Name        | Type | Value     | Description |
| ----------- | ---- | --------- | ----------- |
| PWM_MAX_CNT |      | undefined |             |
## Processes
- pwm_cnt_proc: ( @( posedge clk ) )
  - **Type:** always_ff
