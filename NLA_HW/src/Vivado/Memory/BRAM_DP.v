`timescale 1ns / 100ps

//  Xilinx True Dual Port RAM, No Change, Single Clock
//  This code implements a parameterizable true dual port memory (both ports can read and write).
//  This is a no change RAM which retains the last read value on the output during writes
//  which is the most power efficient mode.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.

module xilinx_true_dual_port_no_change_1_clock_ram #(
  parameter RAM_WIDTH = 32,                                  // Specify RAM data width
  parameter ADDR_LINES = 4,                                 // Specify RAM (number of) address bits
  parameter RAM_DEPTH = 1 << ADDR_LINES                      // RAM depth (number of entries)
) (
  input [ADDR_LINES-1:0] addra,         // Port A address bus, width determined from RAM_DEPTH
  input [ADDR_LINES-1:0] addrb,         // Port B address bus, width determined from RAM_DEPTH
  input [RAM_WIDTH-1:0] dina,           // Port A RAM input data
  input [RAM_WIDTH-1:0] dinb,           // Port B RAM input data
  input clk_i,                          // Clock
  input wea,                            // Port A write enable
  input web,                            // Port B write enable
  input ena,                            // Port A RAM Enable, for additional power savings, disable port when not in use
  input enb,                            // Port B RAM Enable, for additional power savings, disable port when not in use
  input rstna,                          // Port A output reset (does not affect memory contents)
  input rstnb,                          // Port B output reset (does not affect memory contents)
  input regcea,                         // Port A output register enable
  input regceb,                         // Port B output register enable
  output [RAM_WIDTH-1:0] douta,         // Port A RAM output data
  output [RAM_WIDTH-1:0] doutb          // Port B RAM output data
);

  reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_data_a;
  reg [RAM_WIDTH-1:0] ram_data_b;

  always @(posedge clk_i) begin
    if (ena) begin
      if (wea)
        BRAM[addra] <= dina;
      else
        ram_data_a <= BRAM[addra];
    end
  end
  
  always @(posedge clk_i) begin
      if (enb) begin
        if (web)
          BRAM[addrb] <= dinb;
        else
          ram_data_b <= BRAM[addrb];
      end
  end

  generate
    // The following is a 2 clock cycle read latency with improve clock-to-out timing

    reg [RAM_WIDTH-1:0] douta_reg;
    reg [RAM_WIDTH-1:0] doutb_reg;

    always @(posedge clk_i) begin
        if (~rstna)
            douta_reg <= {RAM_WIDTH{1'b0}};
        else if (regcea)
            douta_reg <= ram_data_a;
    end

    always @(posedge clk_i) begin
        if (~rstnb)
            doutb_reg <= {RAM_WIDTH{1'b0}};
        else if (regceb)
            doutb_reg <= ram_data_b;
    end

    assign douta = douta_reg;
    assign doutb = doutb_reg;

  endgenerate

endmodule						
