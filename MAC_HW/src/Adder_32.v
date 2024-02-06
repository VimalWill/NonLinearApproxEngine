`timescale 1ns / 100ps

module adder_32 #(parameter WIDTH = 32)(
    input clk_n,
    input rst_n,
    input [WIDTH - 1:0] A,
    input [WIDTH - 1:0] B,
    output Sign,
    output [WIDTH - 25:0] Exponent,
    output [WIDTH - 10:0] Mantissa
);

    wire comp_w_i;
    wire [WIDTH - 25:0] BigExp_w_i;
    wire [WIDTH - 25:0] SmallExp_w_i;
    wire [WIDTH - 9:0] BigMan_w_i;
    wire [WIDTH - 9:0] SmallMan_w_i;

    wire comp_w_o;
    wire [WIDTH - 25:0] BigExp_w_o;
    wire [WIDTH - 25:0] SmallExp_w_o;
    wire [WIDTH - 9:0] BigMan_w_o;
    wire [WIDTH - 9:0] SmallMan_w_o;
    
    register #(1) comp_reg (
        .clk_n(clk_n),
        .rst_n(rst_n),
        .LD(1'b1),
        .datain(comp_w_i),
        .out(comp_w_o)
    );

    register #(WIDTH - 24) BigExp_reg (
        .clk_n(clk_n),
        .rst_n(rst_n),
        .LD(1'b1),
        .datain(BigExp_w_i),
        .out(BigExp_w_o)
    );

    register #(WIDTH - 24) SmallExp_reg (
        .clk_n(clk_n),
        .rst_n(rst_n),
        .LD(1'b1),
        .datain(SmallExp_w_i),
        .out(SmallExp_w_o)
    );

    register #(WIDTH - 8) BigMan_reg (
        .clk_n(clk_n),
        .rst_n(rst_n),
        .LD(1'b1),
        .datain(BigMan_w_i),
        .out(BigMan_w_o)
    );

    register #(WIDTH - 8) SmallMan_reg (
        .clk_n(clk_n),
        .rst_n(rst_n),
        .LD(1'b1),
        .datain(SmallMan_w_i),
        .out(SmallMan_w_o)
    );

    // Stage 1
    comparator stage_1(
        .A(A[WIDTH - 2:0]), 
        .B(B[WIDTH - 2:0]),
        .comp(comp_w_i), 
        .BigExp(BigExp_w_i), 
        .SmallExp(SmallExp_w_i), 
        .BigMan(BigMan_w_i), 
        .SmallMan(SmallMan_w_i)
    );

    // Stage 2
    shift_add stage_2(
        .comp(comp_w_o),
        .A_sign(A[WIDTH - 1]),
        .B_sign(B[WIDTH - 1]),
        .BigExp(BigExp_w_o),
        .SmallExp(SmallExp_w_o),
        .BigMan(BigMan_w_o),
        .SmallMan(SmallMan_w_o),
        .sign(Sign),
        .Exponent(Exponent),
        .Mantissa(Mantissa)
    );

endmodule