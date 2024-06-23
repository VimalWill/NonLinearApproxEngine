module BadLeadingZero (
    input [23:0] in,
    output reg [4:0] out
 );
    
    integer i;
    always @(*) begin
        out = 'b0;
        for (i = 0 ; i < 24; i = i+1) begin
            if (in[i])
               out = 23 - i;
        end
    end
endmodule
