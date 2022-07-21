
///////////////////////////////////////////////////////////////////////////////
// File: uart_lite.sv
// Copyright (c) 2022. Danilo Ramos
// All rights reserved.
// This license message must appear in all versions of this code including
// modified versions.
////////////////////////////////////////////////////////////////////////////////
// Overview
// Simple UART
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

// Simple UART
module uart_lite
#(
    parameter BAUD_RATE=115200,
    parameter CLK_FREQUENCY=48000000,
    parameter DATA_BITS = 8,
    parameter RX_SAMPLES = 3
)
(
    input wire clk,
    input wire reset,
    
    // TX port
    output logic                 tx_rdy,
    input  wire                  tx_vld,
    input  wire  [DATA_BITS-1:0] tx_data,
    output logic                 tx_uart,
    
    // RX port
    output logic                 rx_valid,
    output logic [DATA_BITS-1:0] rx_data,
    input  logic                 rx_uart
);

localparam rcalc_CLKS_PER_BIT = $rtoi($ceil(CLK_FREQUENCY/BAUD_RATE));
localparam CLKS_PER_BIT_WL = $clog2(rcalc_CLKS_PER_BIT);
localparam CLKS_PER_BIT = rcalc_CLKS_PER_BIT[CLKS_PER_BIT_WL-1:0];

localparam TOTAL_BITS = 1 + DATA_BITS + 1;  // [START=0|DATA[0->T.BITS]|STOP=1]
localparam TOTAL_BITS_WL = $clog2(TOTAL_BITS);

localparam DATA_BITS_WL = $clog2(DATA_BITS);

// --------------------------------------------------------------------------------
logic [CLKS_PER_BIT_WL-1:0] tx_bit_baudrate;
logic   [TOTAL_BITS_WL-1:0] tx_bit_count;
logic    [TOTAL_BITS-1:0] tx_data_buff;

enum {TX_IDLE, TX_DATA_SEND} tx_fsm;
always_ff @(posedge clk) begin : tx_block
    if(reset) begin
        tx_rdy  <= 1'b1;
        tx_uart <= 1'b1;
        tx_fsm  <= TX_IDLE;
        
    end else begin
        case(tx_fsm)
            TX_IDLE: begin
                if(tx_vld) begin: if_tx_new_data
                    tx_rdy          <= 1'b0;
                    tx_bit_baudrate <= '0;
                    tx_bit_count    <= '0;
                    tx_data_buff    <= {1'b1, tx_data, 1'b0};
                    
                    tx_fsm <= TX_DATA_SEND;
                end
            end
            
            TX_DATA_SEND: begin
                tx_uart <= tx_data_buff[tx_bit_count];
                
                if(tx_bit_baudrate < CLKS_PER_BIT) begin: if_sending_bit
                    tx_bit_baudrate <= tx_bit_baudrate + 1;
                    
                end else begin: if_done_sending_bit
                    tx_bit_baudrate <= 'b0;
                    if(tx_bit_count < (TOTAL_BITS-1)) begin: if_more_bits_to_send
                        tx_bit_count <= tx_bit_count + 1;
                        
                    end else begin: if_done_all_bits
                        tx_rdy <= 1'b1;
                        tx_fsm <= TX_IDLE;
                    end
                    
                end
            end
        endcase
    end
end

// --------------------------------------------------------------------------------
localparam RX_SAMPLES_WL = $clog2(RX_SAMPLES);
localparam logic [CLKS_PER_BIT_WL-1:0] RX_SAMPLE_CLKS = CLKS_PER_BIT/(RX_SAMPLES+1);
localparam logic [CLKS_PER_BIT_WL-1:0] RX_LAST_SAMPLE_CLKS = CLKS_PER_BIT-RX_SAMPLES*RX_SAMPLE_CLKS;

logic [DATA_BITS_WL-1:0]  rx_bit_capture_cnt;
logic [RX_SAMPLES_WL-1:0] rx_bit_sample_cnt;
logic [RX_SAMPLES_WL:0]   rx_bit_curr_sample_value;

logic [CLKS_PER_BIT_WL:0] rx_next_sample_clks;
enum {RX_IDLE, RX_SAMPLING, RX_STORE_BIT_VL, RX_STOP_BIT} rx_fsm;

always_ff @(posedge clk) begin : rx_block
    if(reset) begin
        rx_valid <= 1'b0;
        rx_fsm   <= RX_IDLE;
        
    end else begin
        case(rx_fsm)
            RX_IDLE: begin
                rx_valid <= 1'b0;
                if(rx_uart==1'b0) begin: if_rx_new_capture
                    rx_bit_capture_cnt       <= '0;
                    rx_bit_sample_cnt        <= '0;
                    rx_bit_curr_sample_value <= '0;
                    
                    rx_next_sample_clks <= CLKS_PER_BIT + RX_SAMPLE_CLKS;
                    rx_fsm              <= RX_SAMPLING;
                end
            end
            
            RX_SAMPLING: begin
                rx_next_sample_clks <= rx_next_sample_clks - 1;
                if(rx_next_sample_clks == '0) begin: if_sample_bit
                    rx_bit_curr_sample_value <= (rx_uart==1'b1)?(rx_bit_curr_sample_value+1):(rx_bit_curr_sample_value-1);
                    
                    rx_bit_sample_cnt <= rx_bit_sample_cnt + 1;
                    if(rx_bit_sample_cnt==(RX_SAMPLES-1)) begin: if_bit_sample_done
                        rx_bit_sample_cnt        <= '0;
                        rx_next_sample_clks <= {1'b0, RX_LAST_SAMPLE_CLKS};
                        rx_fsm <= RX_STORE_BIT_VL;
                        
                    end else begin
                        rx_next_sample_clks <= {1'b0, RX_SAMPLE_CLKS};
                    end
                end
            end
            
            RX_STORE_BIT_VL: begin
                rx_next_sample_clks <= rx_next_sample_clks - 1;
                if(rx_next_sample_clks == '0) begin: if_store_bit
                    rx_data[rx_bit_capture_cnt] <= (rx_bit_curr_sample_value[RX_SAMPLES_WL]==1'b0)?(1'b1):(1'b0);
                    rx_bit_curr_sample_value <= '0;
                    
                    rx_bit_capture_cnt  <= rx_bit_capture_cnt + 1;
                    if(rx_bit_capture_cnt==(DATA_BITS-1)) begin
                        rx_fsm              <= RX_STOP_BIT;
                        rx_next_sample_clks <= {1'b0, CLKS_PER_BIT>>2};  // OK to exit before stop bit is done
                    end else begin
                        rx_fsm              <= RX_SAMPLING;
                        rx_next_sample_clks <= {1'b0, RX_SAMPLE_CLKS};
                    end
                end
            end
            
            RX_STOP_BIT: begin
                rx_next_sample_clks <= rx_next_sample_clks - 1;
                if(rx_next_sample_clks == '0) begin: if_end_stop_bit
                    rx_valid <= 1'b1;
                    rx_fsm   <= RX_IDLE;
                end
            end
        endcase
    end
end

endmodule: uart_lite

`default_nettype wire
