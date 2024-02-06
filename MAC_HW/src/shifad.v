`timescale 1ns / 100ps

module shift_add (
    input comp, 
    input A_sign,
    input B_sign,
    input [7:0] BigExp, 
    input [7:0] SmallExp, 
    input [23:0] BigMan, 
    input [23:0] SmallMan,
    output sign,
    output [7:0] Exponent,
    output [22:0] Mantissa
);

    integer i;

    reg [7:0] DifferenceExp;
    reg [23:0] Temp_SmallMan;
    reg [22:0] TempMan;
    reg carry, extra;
    reg [7:0] shift;

    assign sign = comp ? A_sign : B_sign;
    
    always @* begin
        DifferenceExp = BigExp - SmallExp;
        Temp_SmallMan = (SmallMan >> DifferenceExp);
        shift = BigExp;
        {carry, extra, TempMan} = (A_sign ~^ B_sign) ? (BigMan + Temp_SmallMan) : (BigMan - Temp_SmallMan);
        if (carry) begin
            TempMan = TempMan >> 1;
            shift   = shift + 1'b1;
        end else begin
            for (i = 0; i < 23; i = i + 1) begin
                if (~extra & ~(TempMan == 'b0)) begin
                    TempMan = TempMan << 1;
                    shift   = shift - 1'b1;
                end
            end
        end
    end
    
    assign Exponent = shift;
    assign Mantissa = TempMan;
    
endmodule