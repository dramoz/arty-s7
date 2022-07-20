//  Xilinx True Dual Port RAM No Change Single Clock
//  This code implements a parameterizable true dual port memory (both ports can read and write).
//  This is a no change RAM which retains the last read value on the output during writes
//  which is the most power efficient mode.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.
module vexriscv_ram #(
  parameter RAM_WIDTH = 32,                     // Specify RAM data width
  parameter RAM_DEPTH = 8192,                   // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "LOW_LATENCY",    // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  parameter INIT_FILE = "../vexriscv_generator/VexRiscvBase/build/main.hex"  // Specify name/location of RAM initialization file if using one (leave blank if not)
)
(
  input wire reset,  // Instruction/Data ports output reset (does not affect memory contents)
  input wire clk,    // Clock
  
  input wire                            ibus_en,    // Instruction Port RAM Enable, for additional power savings, disable port when not in use
  input wire                            ibus_we,    // Instruction Port write enable
  input wire  [$clog2(RAM_DEPTH-1)-1:0] ibus_addr,  // Instruction Port address bus, width determined from RAM_DEPTH
  input wire  [RAM_WIDTH-1:0]           ibus_din,   // Instruction Port RAM input data
  input wire                            ibus_regce, // Instruction Port output register enable
  output wire [RAM_WIDTH-1:0]           ibus_dout,  // Instruction Port RAM output data
  
  input wire                           dbus_en,    // Data Port RAM Enable, for additional power savings, disable port when not in use
  input wire                           dbus_we,    // Data Port write enable
  input wire [$clog2(RAM_DEPTH-1)-1:0] dbus_addr,  // Data Port address bus, width determined from RAM_DEPTH
  input wire [RAM_WIDTH-1:0]           dbus_din,   // Data Port RAM input data
  input wire                           dbus_regce, // Data Port output register enable
  output wire  [RAM_WIDTH-1:0]         dbus_dout   // Data Port RAM output data
)
  reg [RAM_WIDTH-1:0] vexrisc_mem [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ibus_ram_data = {RAM_WIDTH{1'b0}};
  reg [RAM_WIDTH-1:0] dbus_ram_data = {RAM_WIDTH{1'b0}};
  
  reg [RAM_WIDTH-1:0] ibus_dout_reg;
  reg [RAM_WIDTH-1:0] dbus_dout_reg;
  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, vexrisc_mem, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          vexrisc_mem[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge clk)
    if (ibus_en)
      if (ibus_we)
        vexrisc_mem[ibus_addr] <= ibus_din;
      else
        ibus_ram_data <= vexrisc_mem[ibus_addr];

  always @(posedge clk)
    if (dbus_en)
      if (dbus_we)
        vexrisc_mem[dbus_addr] <= dbus_din;
      else
        dbus_ram_data <= vexrisc_mem[dbus_addr];

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign ibus_dout = ibus_ram_data;
       assign dbus_dout = dbus_ram_data;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH-1:0] douta_reg = {RAM_WIDTH{1'b0}};
      reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};

      always @(posedge clk)
        if (reset)
          douta_reg <= {RAM_WIDTH{1'b0}};
        else if (ibus_regce)
          douta_reg <= ibus_ram_data;

      always @(posedge clk)
        if (reset)
          doutb_reg <= {RAM_WIDTH{1'b0}};
        else if (dbus_regce)
          doutb_reg <= dbus_ram_data;

      assign ibus_dout = ibus_dout_reg;
      assign dbus_dout = dbus_dout_reg;

    end
  endgenerate
endmodule: vexriscv_ram
  