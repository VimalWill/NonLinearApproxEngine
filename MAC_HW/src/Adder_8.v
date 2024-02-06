module adder_8 #(parameter WIDTH = 8)
    (
        input [WIDTH - 1:0] A, 
        input [WIDTH - 1:0] B, 
        output reg [WIDTH - 1:0] result
    );

    always @ (*) begin
        result = A + B;
    end
endmodule