module PE5B (
    input wire [31:0] in,
    output reg [4:0] out
);
    always @(*) begin
        casex (in)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1: out = 5'd0;
            32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx10: out = 5'd1;
            32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxx100: out = 5'd2;
            32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxx1000: out = 5'd3;
            32'bxxxxxxxxxxxxxxxxxxxxxxxxxxx10000: out = 5'd4;
            32'bxxxxxxxxxxxxxxxxxxxxxxxxxx100000: out = 5'd5;
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx1000000: out = 5'd6;
            32'bxxxxxxxxxxxxxxxxxxxxxxxx10000000: out = 5'd7;
            32'bxxxxxxxxxxxxxxxxxxxxxxx100000000: out = 5'd8;
            32'bxxxxxxxxxxxxxxxxxxxxxx1000000000: out = 5'd9;
            32'bxxxxxxxxxxxxxxxxxxxxx10000000000: out = 5'd10;
            32'bxxxxxxxxxxxxxxxxxxxx100000000000: out = 5'd11;
            32'bxxxxxxxxxxxxxxxxxxx1000000000000: out = 5'd12;
            32'bxxxxxxxxxxxxxxxxxx10000000000000: out = 5'd13;
            32'bxxxxxxxxxxxxxxxxx100000000000000: out = 5'd14;
            32'bxxxxxxxxxxxxxxxx1000000000000000: out = 5'd15;
            32'bxxxxxxxxxxxxxxx10000000000000000: out = 5'd16;
            32'bxxxxxxxxxxxxxx100000000000000000: out = 5'd17;
            32'bxxxxxxxxxxxxx1000000000000000000: out = 5'd18;
            32'bxxxxxxxxxxxx10000000000000000000: out = 5'd19;
            32'bxxxxxxxxxxx100000000000000000000: out = 5'd20;
            32'bxxxxxxxxxx1000000000000000000000: out = 5'd21;
            32'bxxxxxxxxx10000000000000000000000: out = 5'd22;
            32'bxxxxxxxx100000000000000000000000: out = 5'd23;
            32'bxxxxxxx1000000000000000000000000: out = 5'd24;
            32'bxxxxxx10000000000000000000000000: out = 5'd25;
            32'bxxxxx100000000000000000000000000: out = 5'd26;
            32'bxxxx1000000000000000000000000000: out = 5'd27;
            32'bxxx10000000000000000000000000000: out = 5'd28;
            32'bxx100000000000000000000000000000: out = 5'd29;
            32'bx1000000000000000000000000000000: out = 5'd30;
            32'b10000000000000000000000000000000: out = 5'd31;
            default: out = 5'b00000;
        endcase
    end
endmodule