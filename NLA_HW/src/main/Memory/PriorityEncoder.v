`timescale 1ns / 100ps

module PriorityEncoder #(
    parameter ADDR_LINES = 5
 ) (
    input wire [(1 << ADDR_LINES)-1: 0] in,
    output reg [ADDR_LINES-1: 0] out
 );

    integer i;
    always @(*) begin
        out = {ADDR_LINES{1'bx}}; // don't care if no 'in' bits set
        for (i = (1 << ADDR_LINES)-1 ; i >= 0; i = i-1) if (in[i]) out = i;
    end
endmodule
