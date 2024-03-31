`timescale 1ns / 100ps

module mac #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_LINES = 4
) (
    input clk_i,
    input rstn_i,
    input [DATA_WIDTH - 1:0] signal_fifo,
    input [DATA_WIDTH - 1:0] coeff_fifo,
    output [DATA_WIDTH - 1:0] result
);

    wire [DATA_WIDTH - 1:0] signal_pipe, coeff_pipe;
    wire rst_reg_n;
    wire LD_signal, LD_coeff, LD_result;
    wire full_adder, full_mul;
    wire [ADDR_LINES - 1:0] wr_out;
    wire redo;
    
    SyncFIFO_BRAM #(
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
          .redo_i(redo),
          
          .full_o(full_adder),
          .empty_o(empty_adder),
          
          .start_o(start_coeff),
          
          .wr_en(wr_en_coeff),
          .rd_en(rd_en_coeff),
          .data_i(coeff_fifo),
          .data_o(coeff_pipe)
      );

    datapath #(DATA_WIDTH) pipe (
        .clk_n(clk_i),
        .rst_n(rst_reg_n ^ redo),
        .signal(signal_pipe),
        .coeff(coeff_pipe),
        .LD_signal(LD_signal),
        .LD_coeff(LD_coeff),
        .LD_result(LD_result),
        .result(result)
    );

    controller #(ADDR_LINES) ctrl (
        .clk(clk_i),
        .rst_n(rstn_i),
        .rst_reg_n(rst_reg_n),
        
        .wr_ptr_coeff(wr_out),
        
        .empty(empty_mul),
        
        .start_signal(start_signal),
        .start_coeff(start_coeff),
        
        .wr_en_signal(wr_en_signal),
        .wr_en_coeff(wr_en_coeff),
        .rd_en_signal(rd_en_signal),
        .rd_en_coeff(rd_en_coeff),
        
        .LD_signal(LD_signal),
        .LD_coeff(LD_coeff),
        .LD_result(LD_result),
        
        .redo(redo)
    );
    
endmodule