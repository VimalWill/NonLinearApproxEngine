`timescale 1ns / 100ps

module Coeff_cntr #(
  parameter ADDR_LINES = 4
) (
    input clkn_i,
    input rd_en,
    input redo,
    input [(1 << ADDR_LINES) - 1:0] count,
    output [ADDR_LINES - 1:0] rd_ptr
);
    integer i;
    
    always @(posedge clkn_i) begin
        if (redo)
            i = 'b0;
        else if (count[i] && rd_en)
            i = i + 'b1;

    end
    
    assign rd_ptr = i;

endmodule
