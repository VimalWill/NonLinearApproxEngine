`timescale 1ns / 100ps

module Coeff_cntr #(
  parameter ADDR_LINES = 4
) (
    input wire clkn_i,
    input wire rd_en,
    input wire redo,
    input wire [(1 << ADDR_LINES) - 1:0] count,
    output wire [ADDR_LINES - 1:0] rd_ptr
);
    reg [ADDR_LINES-1:0] i;
    
    always @(posedge clkn_i) begin
        if (redo)
            i = 'b0;
        else if (count[i] && rd_en)
            i = i + 'b1;

    end
    
    assign rd_ptr = i;

endmodule
