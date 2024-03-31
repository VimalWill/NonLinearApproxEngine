module Coeff_cntr #(
  parameter ADDR_LINES = 4
) (
    input rd_en,
    input redo,
    input [15:0] count,
    output [ADDR_LINES - 1:0] rd_ptr
);
    reg [15:0] i = 0;
    
    always @(*) begin
        if (redo)
            i = 16'b0;
        else if (count[i] && rd_en)
            i = i + 'b1;

    end
    
    assign rd_ptr = i;

endmodule