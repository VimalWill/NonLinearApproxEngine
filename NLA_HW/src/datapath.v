`timescale 1ns / 100ps

module datapath #(parameter WIDTH = 32)
    (
        input [WIDTH - 1:0] signal,
        input [WIDTH - 1:0] coeff,
        input clk_n,
        input rst_n,
        input LD_coeff,
        input LD_signal,
        input LD_result,
        output reg [WIDTH - 1:0] result
    );
    
    reg [WIDTH - 1:0] mul_in1, mul_in2, add_in1, add_in2;
    wire [WIDTH - 1:0] adder_result, mul_result;
    
    always @(negedge clk_n or negedge rst_n) begin
        if(~rst_n) begin
            mul_in2 <= 'b0;
        end
        else begin
            if (LD_coeff) begin
                add_in1 <= coeff;
                add_in2 <= mul_result;
            end
            else if(LD_signal) begin
                mul_in1 <= signal;
                mul_in2 <= adder_result;
            end
            else if (LD_result)
                result <= mul_result;
        end
    end
    
    adder_32 #(WIDTH) ADD
        (
            .clk_n(clk_n),
            .rst_n(rst_n), 
            .A(add_in1), 
            .B(add_in2), 
            .Result(adder_result) 
        );
            
    multiply_32 #(WIDTH) MUL
        (
            .A(mul_in1), 
            .B(mul_in2),
            .Result(mul_result)
        );
    
endmodule