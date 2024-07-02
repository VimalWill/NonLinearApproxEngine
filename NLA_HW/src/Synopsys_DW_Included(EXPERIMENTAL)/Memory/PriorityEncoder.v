`timescale 1ns / 100ps

module PriorityEncoder #(
    parameter WIDTH = 4
 ) (
    input wire [(1 << WIDTH)-1: 0] in,
    output reg [WIDTH-1: 0] out
 );
    
    integer i;
    always @(*) begin
        out = 'bx; // don't care if no 'in' bits set
        for (i = (1 << WIDTH)-1 ; i >= 0; i = i-1) begin
            if (in[i])
               out = i;
        end
    end
endmodule
