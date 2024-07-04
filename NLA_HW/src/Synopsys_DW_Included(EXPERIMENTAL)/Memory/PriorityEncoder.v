`timescale 1ns / 100ps

module PriorityEncoder #(
    parameter WIDTH = 5
 ) (
    input wire [WIDTH-1: 0] in,
    output reg [$clog2(WIDTH)-1: 0] out
 );

    integer i;
    always @(*) begin
        out = {$clog2(WIDTH){1'bx}}; // don't care if no 'in' bits set
        for (i = WIDTH-1 ; i >= 0; i = i-1) if (in[i]) out = i;
    end
endmodule
