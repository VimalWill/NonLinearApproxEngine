`timescale 1ns / 100ps

module mac #(parameter WIDTH = 32,
            parameter DEPTH = 4)
    (
        input [WIDTH - 1:0] signal_fifo,
        input [WIDTH - 1:0] coeff_fifo,
        input clk,
        input rst_n,
        output [WIDTH - 1:0] result
    );

    wire [WIDTH - 1:0] signal_pipe, coeff_pipe;
    wire rst_reg_n;
    wire LD_signal, LD_coeff;
    wire empty_adder, full_adder, empty_mul, full_mul;
    wire push;
    
    fifo #(WIDTH, DEPTH) fifo_adder (
        //.clk(clk),
        .rst_n(rst_n),
        .push_i(push),
        .push_data_i(coeff_fifo),
        .pop_i(LD_coeff),
        .pop_data_o(coeff_pipe),
        .full_o(full_adder),
        .empty_o(empty_adder)
    );
    
    fifo #(WIDTH, DEPTH) fifo_mul (
        //.clk(clk),
        .rst_n(rst_n),
        .push_i(push),
        .push_data_i(signal_fifo),
        .pop_i(LD_signal),
        .pop_data_o(signal_pipe),
        .full_o(full_mul),
        .empty_o(empty_mul)
    );

    datapath #(WIDTH) pipe (
        .signal(signal_pipe),
        .coeff(coeff_pipe),
        .clk_n(clk),
        .rst_n(rst_reg_n),
        .LD_signal(LD_signal),
        .LD_coeff(LD_coeff),
        .result(result)
    );

    controller ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .full(full_adder),
        .empty(empty_adder),
        .rst_reg_n(rst_reg_n),
        .LD_signal(LD_signal),
        .LD_coeff(LD_coeff),
        .push(push)
    );

endmodule