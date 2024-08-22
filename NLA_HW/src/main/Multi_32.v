`timescale 1ns / 1ps

module multiply_32 (
    input wire clkn_i,
    input wire rstn_i,
    input wire [31:0] A,
    input wire [31:0] B,
    output wire [31:0] Result
);

    reg [23:0] A_Mantissa, B_Mantissa;
    reg [7:0] A_Exponent, B_Exponent;
    
    reg sign, sign_A, sign_B;
    reg [7:0] Temp_Exponent;
    
    reg sign1, sign2, sign3;
    reg [7:0] Temp_Exponent1, Temp_Exponent2, Temp_Exponent3;
    
    wire [47:0] Temp_Mantissa;
    
    reg [22:0] intermediateMan, ManChoice1, ManChoice2;
    reg [7:0] intermediateExp, ExpChoice1, ExpChoice2;
    reg intermediateSign, signChoice, choice;
    
    localparam bias = 7'b1111111; // 127

    always @ (negedge clkn_i or negedge rstn_i) begin
        if (~rstn_i) begin
            sign_A <= 'b0;
            sign_B <= 'b0;
            A_Mantissa <= 'b0;
            A_Exponent <= 'b0;
            B_Mantissa <= 'b0;
            B_Exponent <= 'b0;
        end else if ((~|A[30:0]) | (~|B[30:0])) begin
            sign_A <= 'b0;
            sign_B <= 'b0;
            A_Mantissa <= 'b0;
            A_Exponent <= 'b0;
            B_Mantissa <= 'b0;
            B_Exponent <= 'b0;
        end else begin
            sign_A <= A[31];
            sign_B <= B[31];
            A_Mantissa <= {1'b1, A[22:0]};
            A_Exponent <= A[30:23] - bias;
            B_Mantissa <= {1'b1, B[22:0]}; 
            B_Exponent <= B[30:23];       
        end 
    end
    
    karatsuba24_12 karatsuba (
        .clkn_i(clkn_i),
        .rstn_i(rstn_i),
        .multiplicand(A_Mantissa),
        .multiplier(B_Mantissa),
        .product(Temp_Mantissa)
    );
    
    always @(negedge clkn_i or negedge rstn_i) begin
        if (~rstn_i) begin
            sign <= 'b0;
            Temp_Exponent <= 'b0;
        end else begin
            sign <= sign_A ^ sign_B;
            Temp_Exponent <= A_Exponent + B_Exponent;
        end
    end
    
    always @( negedge clkn_i or negedge rstn_i) begin
        if (~rstn_i) begin
            Temp_Exponent1 <= 'b0;
            Temp_Exponent2 <= 'b0;
            Temp_Exponent3 <= 'b0;
        end else begin
            Temp_Exponent1 <= Temp_Exponent;
            Temp_Exponent2 <= Temp_Exponent1;
            Temp_Exponent3 <= Temp_Exponent2;
        end
    end
    
    always @( negedge clkn_i or negedge rstn_i) begin
        if (~rstn_i) begin
            sign1 <= 1'b0;
            sign2 <= 1'b0;
            sign3 <= 1'b0;
        end else begin
            sign1 <= sign;
            sign2 <= sign1;
            sign3 <= sign2;
        end
    end

    always @(negedge clkn_i or negedge rstn_i) begin
        if (~rstn_i) begin
            choice <= 'b0;
            signChoice <= 'b0;
            ExpChoice1 <= 'b0;
            ExpChoice2 <= 'b0;
            ManChoice1 <= 'b0;
            ManChoice2 <= 'b0;
        end else begin
            choice <= Temp_Mantissa[47];
            signChoice <= sign3;
            ExpChoice1 <= Temp_Exponent3 + 1'b1;
            ExpChoice2 <= Temp_Exponent3;
            ManChoice1 <= Temp_Mantissa[46:24];
            ManChoice2 <= Temp_Mantissa[45:23];
        end
    end
    
    always @ (negedge clkn_i or negedge rstn_i) begin
        if (~rstn_i) begin
            intermediateSign <= 'b0;
            intermediateExp <= 'b0;
            intermediateMan <= 'b0;
        end else begin
            intermediateSign <= signChoice;
            intermediateExp <= choice ? ExpChoice1 : ExpChoice2;
            intermediateMan <= choice ? ManChoice1 : ManChoice2;      
        end
    end

    assign Result[31] = intermediateSign;
    assign Result[30:23] = intermediateExp;
    assign Result[22:0] = intermediateMan;

endmodule
