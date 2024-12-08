`timescale 1ns / 100ps

module dual_port_ram #(
  parameter DATA_WIDTH = 32,                                 // Specify RAM data width
  parameter ADDR_LINES = 4,                                 // Specify RAM (number of) address bits
  parameter RAM_DEPTH = 1 << ADDR_LINES                     // RAM depth (number of entries)
) (
  input wire [ADDR_LINES-1:0] addra,         // Port A address bus, width determined from RAM_DEPTH
  input wire [ADDR_LINES-1:0] addrb,         // Port B address bus, width determined from RAM_DEPTH
  input wire [DATA_WIDTH-1:0] dina,           // Port A RAM input data
  input wire clk_i,                          // Clock
  input wire wea,                            // Port A write enable
  input wire ena,                            // Port A RAM Enable, for additional power savings, disable port when not in use
  input wire enb,                            // Port B RAM Enable, for additional power savings, disable port when not in use
  input wire rstnb,                          // Port B output reset (does not affect memory contents)
  input wire regceb,                         // Port B output register enable
  output wire [DATA_WIDTH-1:0] doutb          // Port B RAM output data
);

  reg [DATA_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  reg [DATA_WIDTH-1:0] ram_data_b;

  always @(posedge clk_i)
    if (ena)
      if (wea) BRAM[addra] <= dina;

  always @(posedge clk_i)
    if (enb)
      ram_data_b <= BRAM[addrb];

  generate

    reg [DATA_WIDTH-1:0] doutb_reg;

    always @(posedge clk_i) begin
        if (~rstnb)
            doutb_reg <= {DATA_WIDTH{1'b0}};
        else if (regceb)
            doutb_reg <= ram_data_b;
    end

    assign doutb = doutb_reg;

  endgenerate

endmodule
