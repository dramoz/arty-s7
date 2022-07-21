
//  Xilinx True Dual Port RAM Byte Write Read First Single Clock RAM
//  This code implements a parameterizable true dual port memory (both ports can read and write).
//  The behavior of this RAM is when data is written, the prior memory contents at the write
//  address are presented on the output port.

module vexriscv_ram #(
  parameter NB_COL = 4,                       // Specify number of columns (number of bytes)
  parameter COL_WIDTH = 8,                    // Specify column width (byte width, typically 8 or 9)
  parameter RAM_DEPTH = 1024,                 // Specify RAM depth (number of entries)
  parameter INIT_FILE = ""
)
(
  input wire clk,                              // Clock
  
  input wire                            ibus_en,    // Port A RAM Enable, for additional power savings, disable port when not in use
  input wire  [NB_COL-1:0]              ibus_we,    // Port A write enable
  input wire  [$clog2(RAM_DEPTH-1)-1:0] ibus_addr,  // Port A address bus, width determined from RAM_DEPTH
  input wire  [(NB_COL*COL_WIDTH)-1:0]  ibus_din,   // Port A RAM input data
  output wire [(NB_COL*COL_WIDTH)-1:0]  ibus_dout,  // Port A RAM output data
  
  input wire                            dbus_en,    // Port B RAM Enable, for additional power savings, disable port when not in use
  input wire  [NB_COL-1:0]              dbus_we,    // Port B write enable
  input wire  [$clog2(RAM_DEPTH-1)-1:0] dbus_addr,  // Port B address bus, width determined from RAM_DEPTH
  input wire  [(NB_COL*COL_WIDTH)-1:0]  dbus_din,   // Port B RAM input data
  output wire [(NB_COL*COL_WIDTH)-1:0]  dbus_dout   // Port B RAM output data
);
  
  reg [(NB_COL*COL_WIDTH)-1:0] vexriscv_mem[RAM_DEPTH];
  reg [(NB_COL*COL_WIDTH)-1:0] ibus_ram_data = {(NB_COL*COL_WIDTH){1'b0}};
  reg [(NB_COL*COL_WIDTH)-1:0] dbus_ram_data = {(NB_COL*COL_WIDTH){1'b0}};
  
  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      integer inx;
      integer jnx;
      bit [NB_COL*COL_WIDTH-1:0] swap;
      initial begin
        $readmemh(INIT_FILE, vexriscv_mem);
      end
    end else begin: init_bram_to_zero
      integer inx;
      initial
        for (inx = 0; inx < RAM_DEPTH; inx = inx + 1)
          vexriscv_mem[inx] = {(NB_COL*COL_WIDTH){1'b0}};
    end
  endgenerate
  
  generate
    genvar i;
       for (i = 0; i < NB_COL; i = i+1) begin: byte_write
         always @(posedge clk)
           if (ibus_en)
             if (ibus_we[i]) begin
               vexriscv_mem[ibus_addr][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= ibus_din[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
               ibus_ram_data[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= ibus_din[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
             end else begin
               ibus_ram_data[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= vexriscv_mem[ibus_addr][(i+1)*COL_WIDTH-1:i*COL_WIDTH];
             end
             
         always @(posedge clk)
           if (dbus_en)
             if (dbus_we[i]) begin
               vexriscv_mem[dbus_addr][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= dbus_din[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
               dbus_ram_data[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= dbus_din[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
             end else begin
               dbus_ram_data[(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= vexriscv_mem[dbus_addr][(i+1)*COL_WIDTH-1:i*COL_WIDTH];
             end
       end
  endgenerate
  
  assign ibus_dout = ibus_ram_data;
  assign dbus_dout = dbus_ram_data;

endmodule: vexriscv_ram
