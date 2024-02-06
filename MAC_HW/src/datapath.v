`timescale 1ns / 100ps

module datapath #(parameter WIDTH = 32)
    (
        input [WIDTH - 1:0] signal,
        input [WIDTH - 1:0] coeff,
        input clk_n,
        input rst_n,
        input LD_coeff,
        input LD_signal,
        output [WIDTH - 1:0] result
    );
    
    wire [WIDTH - 1:0] mul_in1, mul_in2, add_in1, add_in2;
    
    wire add_sign, mul_sign;
    wire [WIDTH - 25:0] add_exp, mul_exp ;
    wire [WIDTH - 10:0] add_man, mul_man;
    
    //assign add_in1 = coeff;
    register #(WIDTH) coeff_LD(
            .LD(LD_coeff), 
            .clk_n(clk_n), 
            .rst_n(rst_n), 
            .datain(coeff), 
            .out(add_in1));
    
    register #(WIDTH) mul_result(
            .LD(LD_coeff), 
            .clk_n(clk_n), 
            .rst_n(rst_n), 
            .datain({mul_sign, mul_exp, mul_man}), 
            .out(add_in2));

    adder_32 #(WIDTH) ADD(
            .clk_n(clk_n),
            .rst_n(rst_n), 
            .A(add_in1), 
            .B(add_in2), 
            .Sign(add_sign),
            .Exponent(add_exp),
            .Mantissa(add_man));
    
    //assign mul_in1 = signal;
    register #(WIDTH) signal_LD(
            .LD(LD_signal), 
            .clk_n(clk_n), 
            .rst_n(rst_n), 
            .datain(signal), 
            .out(mul_in1));
            
    register #(WIDTH) accum(
            .LD(LD_signal), 
            .clk_n(clk_n), 
            .rst_n(rst_n), 
            .datain({add_sign, add_exp, add_man}), 
            .out(mul_in2));
            
    multiply_32 #(WIDTH) MUL(
            .clk_n(clk_n), 
            .rst_n(rst_n),
            .A(mul_in1), 
            .B(mul_in2),
            .Sign(mul_sign),
            .Exponent(mul_exp),
            .Mantissa(mul_man));
    
    assign result = {add_sign, add_exp, add_man};
    
endmodule