`timescale 1ns / 100ps

module rom_block #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_LINES = 5,
    parameter INIT_FILE = "taylor_coeffs.mem"
) (
    input wire clk_i,
    input wire [ADDR_LINES-1:0] addr,     // Read address
    input wire rd_en_i,                     // Output register enable
    output reg [DATA_WIDTH-1:0] data_o     // Registered output
);

    // Memory array
    reg [DATA_WIDTH-1:0] ROM [(1 << ADDR_LINES)-1:0];

    // Single registered read port
    always @(posedge clk_i) begin
        if (rd_en_i)
            data_o <= ROM[addr];
    end

    // Initialize ROM contents
    initial begin
        $readmemb(INIT_FILE, ROM);
    end

endmodule
