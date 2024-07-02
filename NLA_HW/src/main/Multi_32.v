`timescale 1ns / 100ps

module multiply_32 (
    input wire clk_n,
    input wire rst_n,
    input wire [31:0] A,
    input wire [31:0] B,
    output wire [31:0] Result
);

    reg [23:0] A_Mantissa, B_Mantissa;
    reg [7:0] A_Exponent, B_Exponent;
    
    reg sign, sign_A, sign_B;  
    reg [47:0] Temp_Mantissa;
    reg [7:0] Temp_Exponent;
    
    reg [22:0] intermediateMan, ManChoice1, ManChoice2;
    reg [7:0] intermediateExp, ExpChoice1, ExpChoice2;
    reg intermediateSign, signChoice, choice;
    
    localparam bias = 7'b1111111; // 127

    always @ (negedge clk_n or negedge rst_n) begin
        if (~rst_n) begin
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
    
    always @ (negedge clk_n or negedge rst_n) begin
        if (~rst_n) begin
            sign <= 'b0;
            Temp_Exponent <= 'b0;
            Temp_Mantissa <= 'b0;
        end else begin
            sign <= sign_A ^ sign_B;
            Temp_Exponent <= A_Exponent + B_Exponent;
            Temp_Mantissa <= A_Mantissa * B_Mantissa;
        end
    end

    always @ (negedge clk_n or negedge rst_n) begin
        if (~rst_n) begin
            choice <= 'b0;
            signChoice <= 'b0;
            ExpChoice1 <= 'b0;
            ExpChoice2 <= 'b0;
            ManChoice1 <= 'b0;
            ManChoice2 <= 'b0;
        end else begin
            choice <= Temp_Mantissa[47];
            signChoice <= sign;
            ExpChoice1 <= Temp_Exponent + 1'b1;
            ExpChoice2 <= Temp_Exponent;
            ManChoice1 <= Temp_Mantissa[46:24]; 
            ManChoice2 <= Temp_Mantissa[45:23];     
        end
    end
    
    always @ (negedge clk_n or negedge rst_n) begin
        if (~rst_n) begin
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
