`timescale 1ns / 1ps

module karatsuba24_6 (
    input clkn_i,
    input rstn_i,
    input [23:0] multiplicand,
    input [23:0] multiplier,
    output [47:0] product
);
    wire [11:0] P_high_high, P_high_low, P_low_high, P_low_low;
    wire [13:0] P_middle_low, P_middle_high, P_middle_AD, P_middle_BC;
    
    wire [11:0] ag, bh;
    wire [11:0] ce, df;

    wire [6:0] B, D, A, C;
    
    wire [23:0] P_high, P_low;
    wire [23:0] AD, BC;
    wire [24:0] P_middle;

    wire [5:0] a = multiplicand[23:18];
    wire [5:0] b = multiplicand[17:12];
    wire [5:0] c = multiplicand[11:6];
    wire [5:0] d = multiplicand[5:0];
    wire [5:0] e = multiplier[23:18];
    wire [5:0] f = multiplier[17:12];
    wire [5:0] g = multiplier[11:6];
    wire [5:0] h = multiplier[5:0];

    // product = multiplicand * multiplier = 2^24(AC) + 2^12(AD + BC) + BD

    // Upper AC
    r4booth_6 #(6) booth_mult1 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(a),
        .multiplier(e),
        .product(P_high_high)
    );

    r4booth_6 #(6) booth_mult2 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(b),
        .multiplier(f),
        .product(P_high_low)
    );

    r4booth_7 #(7) booth_mult3 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(A),
        .multiplier(C),
        .product(P_middle_high)
    );

    // Lower BD
    r4booth_6 #(6) booth_mult4 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(c),
        .multiplier(g),
        .product(P_low_high)
    );

    r4booth_6 #(6) booth_mult5 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(d),
        .multiplier(h),
        .product(P_low_low)
    );

    r4booth_7 #(7) booth_mult6 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(B),
        .multiplier(D),
        .product(P_middle_low)
    );
    
    r4booth_6 #(6) booth_mult7 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(g),
        .multiplier(a),
        .product(ag)
    );
    
    r4booth_6 #(6) booth_mult8 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(b),
        .multiplier(h),
        .product(bh)
    );
    
    r4booth_7 #(7) booth_mult9 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(A),
        .multiplier(D),
        .product(P_middle_AD)
    );
    
    r4booth_6 #(6) booth_mult10 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(c),
        .multiplier(e),
        .product(ce)
    );
    
    r4booth_6 #(6) booth_mult11 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(d),
        .multiplier(f),
        .product(df)
    );
    
    r4booth_7 #(7) booth_mult12 (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(B),
        .multiplier(C),
        .product(P_middle_BC)
    );

    assign A = a + b;
    assign B = c + d;
    assign C = e + f;
    assign D = g + h;
    
    assign P_high = (P_high_high << 12) + ((P_middle_high - P_high_high - P_high_low) << 6) + P_high_low;
    assign P_low = (P_low_high << 12) + ((P_middle_low - P_low_high - P_low_low) << 6) + P_low_low;
    
    assign AD = (ag << 12) + ((P_middle_AD - ag - bh) << 6) + bh;
    assign BC = (ce << 12) + ((P_middle_BC - ce - df) << 6) + df;
    assign P_middle = AD + BC;
    
    assign product = (P_high << 24) + (P_middle << 12) + P_low;

endmodule
