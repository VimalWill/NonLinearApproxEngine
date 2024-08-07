`timescale 1ns / 100ps

module datapath #(parameter WIDTH = 32)
    (
        input wire clkn_i,
        input wire rstn_i,
        input wire [WIDTH - 1:0] signal,
        input wire [WIDTH - 1:0] coeff,
        input wire LD_result,
        output reg [WIDTH - 1:0] result
    );

    reg [WIDTH - 1:0] mul_in1, mul_in2, add_in1, add_in2;
    wire [WIDTH - 1:0] adder_result, mul_result;

    always @(negedge clkn_i) begin

        add_in1 <= coeff;
        add_in2 <= mul_result;
        mul_in1 <= signal;
        mul_in2 <= adder_result;

        result <= LD_result ? adder_result : result;
    end

    Adder_32 ADD
    (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .A(add_in1),
        .B(add_in2),
        .Result(adder_result)
    );

    multiply_32 MUL
    (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .A(mul_in1),
        .B(mul_in2),
        .Result(mul_result)
    );

endmodule
