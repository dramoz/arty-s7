//  Xilinx True Dual Port RAM No Change Single Clock
//  This code implements a parameterizable true dual port memory (both ports can read and write).
//  This is a no change RAM which retains the last read value on the output during writes
//  which is the most power efficient mode.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.
module vexriscv_ram #(
    parameter RAM_WIDTH = 32;                     // Specify RAM data width
    parameter RAM_DEPTH = 16384;                  // Specify RAM depth (number of entries)
    parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE"; // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    parameter INIT_FILE = "../vexriscv_generator/VexRiscvBase/build/main.hex";                       // Specify name/location of RAM initialization file if using one (leave blank if not)
  )
  (
    input wire [$clog2(RAM_DEPTH-1)-1:0] ibus_addr;  // Port A address bus, width determined from RAM_DEPTH
    input wire [$clog2(RAM_DEPTH-1)-1:0] dbus_addr;  // Port B address bus, width determined from RAM_DEPTH
    <wire_or_reg> [RAM_WIDTH-1:0] <dina>;           // Port A RAM input data
    <wire_or_reg> [RAM_WIDTH-1:0] <dinb>;           // Port B RAM input data
    <wire_or_reg> <clka>;                           // Clock
    <wire_or_reg> <wea>;                            // Port A write enable
    <wire_or_reg> <web>;                            // Port B write enable
    <wire_or_reg> <ena>;                            // Port A RAM Enable, for additional power savings, disable port when not in use
    <wire_or_reg> <enb>;                            // Port B RAM Enable, for additional power savings, disable port when not in use
    <wire_or_reg> <rsta>;                           // Port A output reset (does not affect memory contents)
    <wire_or_reg> <rstb>;                           // Port B output reset (does not affect memory contents)
    <wire_or_reg> <regcea>;                         // Port A output register enable
    <wire_or_reg> <regceb>;                         // Port B output register enable
    wire [RAM_WIDTH-1:0] <douta>;                   // Port A RAM output data
    wire [RAM_WIDTH-1:0] <doutb>;                   // Port B RAM output data
  )
    reg [RAM_WIDTH-1:0] <ram_name> [RAM_DEPTH-1:0];
    reg [RAM_WIDTH-1:0] <ram_data_a> = {RAM_WIDTH{1'b0}};
    reg [RAM_WIDTH-1:0] <ram_data_b> = {RAM_WIDTH{1'b0}};
  
    // The following code either initializes the memory values to a specified file or to all zeros to match hardware
    generate
      if (INIT_FILE != "") begin: use_init_file
        initial
          $readmemh(INIT_FILE, <ram_name>, 0, RAM_DEPTH-1);
      end else begin: init_bram_to_zero
        integer ram_index;
        initial
          for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
            <ram_name>[ram_index] = {RAM_WIDTH{1'b0}};
      end
    endgenerate
  
    always @(posedge <clka>)
      if (<ena>)
        if (<wea>)
          <ram_name>[<addra>] <= <dina>;
        else
          <ram_data_a> <= <ram_name>[<addra>];
  
    always @(posedge <clka>)
      if (<enb>)
        if (<web>)
          <ram_name>[<addrb>] <= <dinb>;
        else
          <ram_data_b> <= <ram_name>[<addrb>];
  
    //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
    generate
      if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register
  
        // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
         assign <douta> = <ram_data_a>;
         assign <doutb> = <ram_data_b>;
  
      end else begin: output_register
  
        // The following is a 2 clock cycle read latency with improve clock-to-out timing
  
        reg [RAM_WIDTH-1:0] douta_reg = {RAM_WIDTH{1'b0}};
        reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};
  
        always @(posedge <clka>)
          if (<rsta>)
            douta_reg <= {RAM_WIDTH{1'b0}};
          else if (<regcea>)
            douta_reg <= <ram_data_a>;
  
        always @(posedge <clka>)
          if (<rstb>)
            doutb_reg <= {RAM_WIDTH{1'b0}};
          else if (<regceb>)
            doutb_reg <= <ram_data_b>;
  
        assign <douta> = <douta_reg>;
        assign <doutb> = <doutb_reg>;
  
      end
    endgenerate
endmodule: vexriscv_ram
  