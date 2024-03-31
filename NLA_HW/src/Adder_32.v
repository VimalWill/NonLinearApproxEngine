`timescale 1ns / 100ps

module adder_32 #(parameter WIDTH = 32)(
    input clk_n,
    input rst_n,
    input [WIDTH - 1:0] A,
    input [WIDTH - 1:0] B,
    output [WIDTH - 1:0] Result
);

    reg comp_r_i;
    reg [WIDTH - 25:0] BigExp_r_i;
    reg [WIDTH - 25:0] SmallExp_r_i;
    reg [WIDTH - 9:0] BigMan_r_i;
    reg [WIDTH - 9:0] SmallMan_r_i;

    wire comp_w_o;
    wire [WIDTH - 25:0] BigExp_w_o;
    wire [WIDTH - 25:0] SmallExp_w_o;
    wire [WIDTH - 9:0] BigMan_w_o;
    wire [WIDTH - 9:0] SmallMan_w_o;
    
    always @(negedge clk_n or negedge rst_n) begin
        if (~rst_n) begin
            comp_r_i <= 'b0;
            BigExp_r_i <= 'b0;
            SmallExp_r_i <= 'b0;
            BigMan_r_i <= 'b0;
            SmallMan_r_i <= 'b0;
        end
        else begin
            comp_r_i <= comp_w_o;
            BigExp_r_i <= BigExp_w_o;
            SmallExp_r_i <= SmallExp_w_o;
            BigMan_r_i <= BigMan_w_o;
            SmallMan_r_i <= SmallMan_w_o;
        end
    end

    // Stage 1
    comparator stage_1(
        .A(A[WIDTH - 2:0]), 
        .B(B[WIDTH - 2:0]),
        .comp(comp_w_o), 
        .BigExp(BigExp_w_o), 
        .SmallExp(SmallExp_w_o), 
        .BigMan(BigMan_w_o), 
        .SmallMan(SmallMan_w_o)
    );

    // Stage 2
    shift_add stage_2(
        .comp(comp_r_i),
        .A_sign(A[WIDTH - 1]),
        .B_sign(B[WIDTH - 1]),
        .BigExp(BigExp_r_i),
        .SmallExp(SmallExp_r_i),
        .BigMan(BigMan_r_i),
        .SmallMan(SmallMan_r_i),
        .result(Result)
    );

endmodule
