# Entity: hc_sr04_distance_sensor 

- **File**: hc_sr04_distance_sensor.sv
## Diagram

![Diagram](hc_sr04_distance_sensor.svg "Diagram")
## Generics

| Generic name     | Type | Value     | Description |
| ---------------- | ---- | --------- | ----------- |
| CLK_FREQ         |      | 100000000 |             |
| PING_FREQ        |      | 100       |             |
| TRIG_DURATION_US |      | 10        |             |
| MAX_DISTANCE_M   |      | 4         |             |
| O_WL             |      | 32        |             |
## Ports

| Port name  | Direction | Type       | Description |
| ---------- | --------- | ---------- | ----------- |
| reset      | input     | wire       |             |
| clk        | input     | wire       |             |
| sn_trigger | output    |            |             |
| sn_edge    | input     | wire       |             |
| o_valid    | output    |            |             |
| edge_ticks | output    | [O_WL-1:0] |             |
## Signals

| Name           | Type                    | Description |
| -------------- | ----------------------- | ----------- |
| ping_trigg_cnt | logic [PING_CNT_WL-1:0] |             |
| edge_d         | logic                   |             |
| edge_cnt       | logic [EDGE_CNT_WL-1:0] |             |
## Constants

| Name            | Type | Value                                  | Description |
| --------------- | ---- | -------------------------------------- | ----------- |
| SOUND_SPEED_M_S |      | 340                                    |             |
| MAX_TIME        | real | ((2*MAX_DISTANCE_M)/SOUND_SPEED_M_S)   |             |
| EDGE_CNT_WL     |      | $clog2(int'(real'(CLK_FREQ)*MAX_TIME)) |             |
| PING_CNT        |      | undefined                              |             |
| TRIG_CNT        |      | undefined                              |             |
| PING_CNT_WL     |      | $clog2(PING_CNT+TRIG_CNT+1)            |             |
## Processes
- distance_sensor_trigger_proc: ( @( posedge clk ) )
  - **Type:** always_ff
- distance_sensor_measure_proc: ( @( posedge clk ) )
  - **Type:** always_ff
