`timescale 1ns / 100ps

module shift_add (

    input mode,
    input comp,
    input magcheck,
    input zero,
    input A_sign,
    input B_sign,
    input [7:0] BigExp,
    input [7:0] SmallExp,
    input [23:0] BigMan,
    input [23:0] SmallMan,
    output [31:0] result
);

    integer i;
    wire sign;

    assign sign = (comp | magcheck) ? A_sign : (zero ? 1'b0 : (mode ? B_sign : ~B_sign));

    reg [7:0] DifferenceExp;
    reg [23:0] Temp_SmallMan;
    reg [23:0] TempMan;
    reg carry;
    reg [7:0] shift;

    always @(*) begin
        DifferenceExp = BigExp - SmallExp;
        Temp_SmallMan = (SmallMan >> DifferenceExp);
        shift = BigExp;
      	//{carry, TempMan} = (A_sign ^ B_sign) ? (BigMan - Temp_SmallMan) : (BigMan + Temp_SmallMan); // Pure Addition
      	//{carry, TempMan} = (A_sign ^ B_sign) ? (BigMan + Temp_SmallMan) : (BigMan - Temp_SmallMan); // Pure Substraction
      	{carry, TempMan} = (A_sign ^ B_sign ^ mode) ? (BigMan - Temp_SmallMan) : (BigMan + Temp_SmallMan); // Combined
        if (carry) begin
            TempMan = TempMan >> 1;
            shift   = shift + 1'b1;
        end else begin
            for (i = 0; i < 23; i = i + 1) begin
                if (~TempMan[23] && ~(TempMan[22:0] == 'b0)) begin
                    TempMan = TempMan << 1;
                    shift  = shift - 1'b1;
                end
            end
        end
    end

    assign result = {sign, shift, TempMan[22:0]};

endmodule
