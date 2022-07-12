# Entity: arty_s7_test 

- **File**: arty_s7_test.sv
## Diagram

![Diagram](arty_s7_test.svg "Diagram")
## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| rst       | input     | wire        |             |
| clk       | input     | wire        |             |
| sw        | input     | wire  [3:0] |             |
| btn       | input     | wire  [3:0] |             |
| led       | output    | [3:0]       |             |
| led0_r    | output    |             |             |
| led0_g    | output    |             |             |
| led0_b    | output    |             |             |
| led1_r    | output    |             |             |
| led1_g    | output    |             |             |
| led1_b    | output    |             |             |
## Signals

| Name     | Type         | Description |
| -------- | ------------ | ----------- |
| rled_cnt | logic [23:0] |             |
| rled_pwm | logic        |             |
| gled_pwm | logic        |             |
| bled_pwm | logic        |             |
## Constants

| Name            | Type | Value                    | Description |
| --------------- | ---- | ------------------------ | ----------- |
| CLK_FREQ        |      | 12000000                 |             |
| RLED_PWM_FREQ   |      | 5000                     |             |
| RLED_PWM_DCYCLE |      | int'(0.25*RLED_PWM_FREQ) |             |
| GLED_PWM_FREQ   |      | 10000                    |             |
| GLED_PWM_DCYCLE |      | int'(0.50*GLED_PWM_FREQ) |             |
| BLED_PWM_FREQ   |      | 20000                    |             |
| BLED_PWM_DCYCLE |      | int'(0.75*BLED_PWM_FREQ) |             |
## Processes
- rled_cnt_proc: ( @( posedge clk ) )
  - **Type:** always_ff
## Instantiations

- rled_pwm_inst: pwm
- gled_pwm_inst: pwm
- bled_pwm_inst: pwm
