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
// s = d / t -> time is double (go and back)
// -> s = d / (t/2)
//
// 2cm -> 34000cm/s = 2cm / (t/2)
//        34000cm/s = 4cm / t
//        t         = 4s/34000
//      => t = 0.0001176471s -> 117.65 us, 1cm -> 58.825us
//
// 4m  -> 340m/s = 4m/(t/2)
//        340m/s = 8m/t
//        t      = 8s/340
//      => t = 0.0235294118s -> 2.352 ms -> 2352 us
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module hc_sr04_distance_sensor
#(
  parameter CLK_FREQ         = 100000000,
  parameter PING_FREQ        = 100,
  parameter TRIG_DURATION_US = 10,
  parameter MAX_DISTANCE_M   = 4,
  parameter WL               = $clog2(MAX_DISTANCE_M*100 + 1)
)
(
  input  wire reset,
  input  wire clk,
  
  output logic sn_trigger,
  input  wire  sn_edge,
  
  output logic          distance_vld,
  output logic [WL-1:0] distance_cm
);
  localparam SOUND_SPEED_M_S = 340;
  
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
  
  localparam MAX_TIME_US = int'( (2*MAX_DISTANCE_M*1e6)/SOUND_SPEED_M_S);
  localparam EDGE_CNT_WL = 32;
  
  logic                   edge_d;
  logic [EDGE_CNT_WL-1:0] edge_cnt;
  always_ff @( posedge clk ) begin: distance_sensor_measure_proc
    if(reset) begin
      edge_d      <= 1'b0;
      edge_cnt    <= '0;
      distance_vld <= 1'b0;
      distance_cm  <= '0;
      
    end else begin
      edge_d <= sn_edge;
      
      if(edge_d && !sn_edge) begin
        edge_cnt     <= '0;
        distance_vld <= 1;
        distance_cm  <= edge_cnt;
        
      end else begin
        distance_vld <= 0;
        if(sn_edge) begin
          edge_cnt <= edge_cnt + 1;
        end
      end
    end
  end: distance_sensor_measure_proc
  
endmodule: hc_sr04_distance_sensor

`default_nettype wire
