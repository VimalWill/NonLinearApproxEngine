`timescale 1ns / 1ps

module SyncFIFO_BRAM_tb;

    // Parameters
    parameter RAM_WIDTH = 32;
    parameter ADDR_LINES = 4;
    parameter CLK_PERIOD = 10; // Clock period in ns

    // Signals
    reg clk;
    reg rstn_i;
    reg wr_en;
    reg rd_en;
    reg [RAM_WIDTH-1:0] data_i;
    wire [RAM_WIDTH-1:0] data_o;

    // Instantiate the module under test
    SyncFIFO_BRAM #(
        .RAM_WIDTH(RAM_WIDTH),
        .ADDR_LINES(ADDR_LINES)
    ) dut (
        .clk_i(clk),
        .rstn_i(rstn_i),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_i(data_i),
        .data_o(data_o)
    );

    // Clock generation
    always #((CLK_PERIOD / 2)) clk = ~clk;

    // Monitor
    initial begin
//        $dumpfile("SyncFIFO_BRAM_tb.vcd");
//        $dumpvars(0, SyncFIFO_BRAM_tb);
        $monitor("Time=%0t clk=%b rstn_i=%b wr_en=%b rd_en=%b data_i=%h data_o=%h", $time, clk, rstn_i, wr_en, rd_en, data_i, data_o);
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        clk = 0;
        rstn_i = 0;
        wr_en = 0;
        rd_en = 0;
        data_i = 0;

        // Release reset
        #100;
        rstn_i = 1;

//        // Test Case 1: Write data to FIFO
//        wr_en = 1;
//        data_i = 32'h12345678;
//        #20;
//        wr_en = 0;
//        #10;
//        rd_en = 1;
//        #10;
//        rd_en = 0;

        // Test Case 2: Write multiple data to FIFO
        wr_en = 1;
        data_i = 32'hAAAAAAAA;
        #20;
        data_i = 32'hBBBBBBBB;
        #20;
        data_i = 32'hCCCCCCCC;
        #20;
        wr_en = 0;
        #10;
        rd_en = 1;
        #50;
        rd_en = 0;

        // Add more test scenarios as needed

        // Finish simulation
        #10;
        $finish;
    end

endmodule