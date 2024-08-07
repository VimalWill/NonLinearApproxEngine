`timescale 1ns / 1ps

module karatsuba24_12 (
    input clkn_i,
    input rstn_i,
    input [23:0] A,
    input [23:0] B,
    output [47:0] product
);
    wire [23:0] P_high, P_low;
    wire [25:0] P_middle;
    
    wire [12:0] temp1, temp2;

    wire [11:0] A_high = A[23:12];
    wire [11:0] A_low  = A[11:0];
    wire [11:0] B_high = B[23:12];
    wire [11:0] B_low  = B[11:0];
    
    // Instantiate Booth multipliers
    r4booth_even #(12) booth_mult1 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(A_low),
        .multiplier(B_low),
        .product(P_low)
    );

    r4booth_even #(12) booth_mult2 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(A_high),
        .multiplier(B_high),
        .product(P_high)
    );

    r4booth_odd #(13) booth_mult3 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(temp1),
        .multiplier(temp2),
        .product(P_middle)
    );
    
    assign temp1 = A_high + A_low;
    assign temp2 = B_high + B_low;
    
    assign product = (P_high << 24) + ((P_middle - P_high - P_low) << 12) + P_low;

endmodule
