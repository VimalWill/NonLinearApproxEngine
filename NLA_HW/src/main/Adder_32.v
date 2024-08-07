`timescale 1ns / 100ps

module Adder_32 (
     input wire clkn_i,
     input wire rstn_i,
     input wire [31:0] A,
     input wire [31:0] B,
     output wire [31:0] Result
 );
    
    wire [4:0] zerocount;
    
    reg Sign;
    reg [7:0] Exponent;
    reg [22:0] Mantissa;
    
    wire comp, magcheck, zero;
    reg carry, check, check_delayed, check_delayed_delayed;
    reg [7:0] BigExp, BigExp_delayed, BigExp_delayed_delayed, BigExp_delayed_delayed_delayed, SmallExp, DifferenceExp;
    reg [23:0] BigMan, BigMan_delayed, BigMan_delayed_delayed, SmallMan, SmallMan_delayed, Temp_SmallMan, TempMan;
    
    reg A_sign, B_sign;
    
    reg sign, sign_delayed, sign_delayed_delayed, sign_delayed_delayed_delayed;
    
    reg [7:0] A_Exp, B_Exp;
    reg [22:0] A_Man, B_Man;

    always @(negedge clkn_i or negedge rstn_i) begin
        if (~rstn_i) begin
            A_sign <= 1'b0;
            B_sign <= 1'b0;
            A_Exp <= 8'b0;
            B_Exp <= 8'b0;
            A_Man <= 23'b0;
            B_Man <= 23'b0;
        end else begin
            A_sign <= A[31];
            B_sign <= B[31];
            A_Exp <= A[30:23];
            B_Exp <= B[30:23];
            A_Man <= A[22:0];
            B_Man <= B[22:0];
        end
    end
    
    assign comp = (A_Exp > B_Exp) ? 1'b1 : 1'b0;
    assign magcheck = (A_Exp ^ B_Exp) ? 1'b0 : ((A_Man > B_Man) ? 1'b1 : 1'b0);
    assign zero = (~|{A_Exp, A_Man} && ~|{B_Exp, B_Man});
    
    always @(negedge clkn_i or negedge rstn_i) begin
        if (~rstn_i) begin
            check <= 1'b0;
            sign <= 1'b0;
            BigExp <= 8'b0;
            SmallExp <= 8'b0;
            BigMan <= 24'b0;
            SmallMan <= 24'b0;
        end else begin
            check <= A_sign ^ B_sign;
            sign <= (comp | magcheck) ? A_sign : (zero ? 1'b0 : B_sign);
            
            if (zero) begin
                BigExp <= 8'b0;
                SmallExp <= 8'b0;
                BigMan <= 24'b0;
                SmallMan <= 24'b0;                  
            end else begin
                BigExp <= comp ? A_Exp : B_Exp;
                SmallExp <= comp ? B_Exp : A_Exp;
                
                BigMan[23] <= 1'b1;
                SmallMan[23] <= 1'b1;
                
                BigMan[22:0] <= (comp | magcheck) ? A_Man : B_Man;
                SmallMan[22:0] <= (comp | magcheck) ? B_Man : A_Man;
            end
        end
    end
     
    always @(negedge clkn_i or negedge rstn_i) begin
        if (~rstn_i) begin
            DifferenceExp <= 8'b0;
            sign_delayed <= 1'b0;
            SmallMan_delayed <= 24'b0;
            BigExp_delayed <= 8'b0;
            BigMan_delayed <= 24'b0;
            check_delayed <= 1'b0;
        end else begin
            DifferenceExp <= BigExp - SmallExp;
            
            sign_delayed <= sign;
            SmallMan_delayed <= SmallMan;
            BigExp_delayed <= BigExp;
            BigMan_delayed <= BigMan;
            check_delayed <= check;
        end
    end
    
    always @(negedge clkn_i or negedge rstn_i) begin
        if (~rstn_i) begin
            Temp_SmallMan <= 24'b0;
            sign_delayed_delayed <= 1'b0;
            BigExp_delayed_delayed <= 8'b0;
            BigMan_delayed_delayed <= 24'b0;
            check_delayed_delayed <= 1'b0;
        end else begin
            Temp_SmallMan <= SmallMan_delayed >> DifferenceExp;
            
            sign_delayed_delayed <= sign_delayed; 
            BigExp_delayed_delayed <= BigExp_delayed;
            BigMan_delayed_delayed <= BigMan_delayed;
            check_delayed_delayed <= check_delayed;
        end
    end
    
    always @(negedge clkn_i or negedge rstn_i) begin
        if (~rstn_i) begin
            carry <= 1'b0;
            TempMan <= 24'b0;
            sign_delayed_delayed_delayed <= 1'b0;
            BigExp_delayed_delayed_delayed <= 8'b0;
        end else begin
            {carry, TempMan} <= check_delayed_delayed ? (BigMan_delayed_delayed - Temp_SmallMan) : (BigMan_delayed_delayed + Temp_SmallMan);
            
            sign_delayed_delayed_delayed <= sign_delayed_delayed;
            BigExp_delayed_delayed_delayed <= BigExp_delayed_delayed;
        end
    end    

    cntlz24 stage_31 (      // Leading Zero Counter
        .i(TempMan),
        .o(zerocount)
    );
    
    always @(negedge clkn_i or negedge rstn_i) begin
        if (~rstn_i) begin
            Sign <= 'b0;
            Exponent <= 'b0;
            Mantissa <= 'b0;
        end else begin
            if (carry) begin
                Mantissa <= TempMan[23:1];
                Exponent <= BigExp_delayed_delayed_delayed + 1; 
            end
            else if (|TempMan[22:0]) begin
                Mantissa <= TempMan[22:0] << zerocount;
                Exponent <= BigExp_delayed_delayed_delayed - {3'b0, zerocount};
            end else begin
                Mantissa <= TempMan[22:0];
                Exponent <= BigExp_delayed_delayed_delayed;
            end
            Sign <= sign_delayed_delayed_delayed;
        end
    end
    
    assign Result[31] = Sign;
    assign Result[30:23] = Exponent;
    assign Result[22:0] = Mantissa[22:0];

endmodule
