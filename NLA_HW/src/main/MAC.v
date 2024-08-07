`timescale 1ns / 100ps

module mac #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_LINES = 4
) (
    input wire clk_i,
    input wire rstn_i,
    input wire [DATA_WIDTH - 1:0] signal_fifo,
    input wire [DATA_WIDTH - 1:0] coeff_fifo,
    output wire full_adder, full_mul,
    output wire empty_adder, empty_mul,
    output wire [DATA_WIDTH - 1:0] result
);

    wire [DATA_WIDTH - 1:0] signal_pipe, coeff_pipe;
    wire [ADDR_LINES - 1:0] wr_out;

    wire start_signal, start_coeff, wr_en_signal, wr_en_coeff, rd_en_signal, rd_en_coeff, redo_coeff, redo_data, LD_result;

    InputFIFO #(
          .RAM_WIDTH(DATA_WIDTH),
          .ADDR_LINES(ADDR_LINES)
      ) fifo_signal (
          .clk_i(clk_i),
          .rstn_i(rstn_i),

          .full_o(full_mul),
          .empty_o(empty_mul),

          .start_o(start_signal),

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

          .wr_out(wr_out),
          .redo_i(redo_coeff),

          .full_o(full_adder),
          .empty_o(empty_adder),

          .start_o(start_coeff),

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

        .wr_ptr_coeff(wr_out),

        .start_signal(start_signal),
        .start_coeff(start_coeff),

        .wr_en_signal(wr_en_signal),
        .wr_en_coeff(wr_en_coeff),
        .rd_en_signal(rd_en_signal),
        .rd_en_coeff(rd_en_coeff),

        .LD_result(LD_result),

        .redo_coeff(redo_coeff),
        .redo_data(redo_data)
    );

endmodule
