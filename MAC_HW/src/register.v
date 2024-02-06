`timescale 1ns / 100ps

module register #(parameter WIDTH = 8) 
    (
        input clk_n,
        input rst_n,
        input LD,
        input [WIDTH - 1:0] datain,
        output reg [WIDTH - 1:0] out
    );

    always @(negedge clk_n, negedge rst_n) begin

        if (~rst_n) begin
            out <= {WIDTH{1'b0}};
        end
        else if (LD) begin
            out <= datain;
        end
        else
            out <= out;
    end

endmodule