///////////////////////////////////////////////////////////////////////////////
// File: hc_sr04_distance_sensor.sv
// Copyright (c) 2022. Danilo Ramos
// All rights reserved.
// This license message must appear in all versions of this code including
// modified versions.
////////////////////////////////////////////////////////////////////////////////
// Overview
// HC-SR04 Ultrasound distance sensor
// - Wait N ms, send a pulse of 10us
// - Measure ECHO Pin length, report back measurement in cm
//
// range: 0.002 ~ 4 meters
// speed of sound: 340 m/s or 0.034 cm/µs (https://www.engineersedge.com/physics/speed_of_sound_13241.htm)
// -> 34000 cm/s, 34000/1000000 cm/us -> 0.034 cm/us
//
//   1s  -> 340m 
// 100ms ->  34m
//  10ms ->   3.4m
//   1ms ->     34cm
// 
// Max. time measure (range 4m -> 2xtime of flight => 8m)
// s*t = d
// 8/340 -> 23.6ms
//
// Min. time measure (range 2cm -> 2xtime of flight => 4cm -> 0.04m)
// s*t = d
// 0.04/340 -> 0.000118s -> 118us
//
// Distance
// n-ticks, 10e-9 * N = t
// d = s*t = 34000 cm/s * 10e-9 * N
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module hc_sr04_distance_sensor
#(
  parameter CLK_FREQ         = 100000000,
  parameter PING_FREQ        = 100,
  parameter TRIG_DURATION_US = 10,
  parameter MAX_DISTANCE_M   = 4,
  parameter O_WL             = 32
)
(
  input  wire reset,
  input  wire clk,
  
  output logic sn_trigger,
  input  wire  sn_edge,
  
  output logic            o_valid,
  output logic [O_WL-1:0] edge_ticks
);
  localparam SOUND_SPEED_M_S = 340;
  localparam real MAX_TIME = ((2*MAX_DISTANCE_M)/SOUND_SPEED_M_S);
  localparam EDGE_CNT_WL = $clog2(int'(real'(CLK_FREQ)*MAX_TIME));
  
  localparam PING_CNT    = int'(CLK_FREQ/PING_FREQ);
  localparam TRIG_CNT = int'((TRIG_DURATION_US*CLK_FREQ)/1e6);
  localparam PING_CNT_WL = $clog2(PING_CNT+TRIG_CNT+1);
  
  logic [PING_CNT_WL-1:0] ping_trigg_cnt;
  always_ff @( posedge clk ) begin: distance_sensor_trigger_proc
    if(reset) begin
      ping_trigg_cnt <= '0;
      sn_trigger     <= '0;
      
    end else begin
      if(ping_trigg_cnt < (PING_CNT+TRIG_CNT)) begin
        ping_trigg_cnt <= ping_trigg_cnt + 1;
      end else begin
        ping_trigg_cnt <= '0;
      end
      
      sn_trigger <= (ping_trigg_cnt < PING_CNT) ? (0) : (1);
    end
  end: distance_sensor_trigger_proc
  
  
  logic                   edge_d;
  logic [EDGE_CNT_WL-1:0] edge_cnt;
  always_ff @( posedge clk ) begin: distance_sensor_measure_proc
    if(reset) begin
      edge_d      <= 1'b0;
      edge_cnt    <= '0;
      o_valid <= 1'b0;
      edge_ticks  <= '0;
      
    end else begin
      edge_d <= sn_edge;
      
      if(edge_d && !sn_edge) begin
        edge_cnt     <= '0;
        o_valid <= 1;
        
        edge_ticks           <= '0;
        edge_ticks[O_WL-1:0] <= edge_cnt;
        
      end else begin
        o_valid <= 0;
        if(sn_edge) begin
          if(edge_cnt != '1) begin
            edge_cnt <= edge_cnt + 1;
          end
        end
      end
    end
  end: distance_sensor_measure_proc
  
endmodule: hc_sr04_distance_sensor

`default_nettype wire
