`timescale 1ns / 100ps

module mac #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_LINES = 5
) (
    input wire clk_i,
    input wire rstn_i,
    input wire [DATA_WIDTH - 1:0] signal_fifo,
    input wire [DATA_WIDTH - 1:0] coeff_fifo,
    input wire [ADDR_LINES-1:0] taylor_length,
    input wire wr_en_coeff, last_coeff,
    input wire wr_en_signal, last_signal,
    output wire full_adder, empty_adder, idle_coeff,
    output wire full_mul, empty_mul, idle_signal,
    output wire [DATA_WIDTH - 1:0] result
);

    wire [DATA_WIDTH - 1:0] signal_pipe, coeff_pipe;

    wire rd_en_signal, rd_en_coeff, redo_coeff, redo_data, LD_result;

    InputFIFO #(
          .RAM_WIDTH(DATA_WIDTH),
          .ADDR_LINES(ADDR_LINES)
      ) fifo_signal (
          .clk_i(clk_i),
          .rstn_i(rstn_i),

          .full_o(full_mul),
          .empty_o(empty_mul),
          .idle_o(idle_signal),

          .wr_en(wr_en_signal),
          .rd_en(rd_en_signal),
          
          .data_i(signal_fifo),
          .data_o(signal_pipe)
      );

    CoeffFIFO #(
          .RAM_WIDTH(DATA_WIDTH),
          .ADDR_LINES(ADDR_LINES)
      ) fifo_coeff (
          .clk_i(clk_i),
          .rstn_i(rstn_i),

          .redo_i(redo_coeff),

          .full_o(full_adder),
          .empty_o(empty_adder),
          .idle_o(idle_coeff),

          .wr_en(wr_en_coeff),
          .rd_en(rd_en_coeff),
          
          .data_i(coeff_fifo),
          .data_o(coeff_pipe)
      );

    datapath #(DATA_WIDTH) pipe (
        .clkn_i(clk_i),
        .rstn_i(redo_data),
        .signal(signal_pipe),
        .coeff(coeff_pipe),
        .LD_result(LD_result),
        .result(result)
    );

    controller #(ADDR_LINES) ctrl (
        .clk_i(clk_i),
        .rstn_i(rstn_i),

        .coeff_count(taylor_length+1'b1),

        .start_signal(last_signal),
        .start_coeff(last_coeff),

        .rd_en_signal(rd_en_signal),
        .rd_en_coeff(rd_en_coeff),

        .LD_result(LD_result),

        .redo_coeff(redo_coeff),
        .redo_data(redo_data)
    );

endmodule
