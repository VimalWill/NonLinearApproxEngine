`timescale 1ns / 100ps

// Controller with cyclic counter
module CoeffROM #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_LINES = 5,
    parameter INIT_FILE = "taylor_coeffs.mem"
) (
    input wire clk_i,
    input wire rd_en_i,
    input wire [ADDR_LINES-1:0] coeff_addr_i,

    output wire [DATA_WIDTH-1:0] data_o
);

    rom_block #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_LINES(ADDR_LINES),
        .INIT_FILE(INIT_FILE)
    ) ROM (
        .clk_i(clk_i),
        .addr(coeff_addr_i),
        .rd_en_i(rd_en_i),
        .data_o(data_o)
    );

endmodule
