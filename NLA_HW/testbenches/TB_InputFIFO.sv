`timescale 1ns / 1ps

module TB_InputFIFO;

    parameter RAM_WIDTH = 32;
    parameter ADDR_LINES = 5;
    parameter CLK_PERIOD = 10;

    reg clk;
    reg rstn_i;
    reg wr_en;
    reg rd_en;
    reg [RAM_WIDTH-1:0] data_i;
    wire [RAM_WIDTH-1:0] data_o;
    wire full_o, empty_o, idle_o;

    reg [RAM_WIDTH-1:0] signal_sigmoid [0:29] = {
        32'b11000000101000000000000000000000, 32'b11000000100101001111011100101101, 32'b11000000100010011110111001011001,
        32'b11000000011111011100101100001001, 32'b11000000011001111011100101100001, 32'b11000000010100011010011110111001,
        32'b11000000001110111001011000010001, 32'b11000000001001011000010001101001, 32'b11000000000011110111001011000011,
        32'b10111111111100101100001000110101, 32'b10111111110001101001111011100101, 32'b10111111100110100111101110010111,
        32'b10111111010111001011000010001101, 32'b10111111000001000110100111101111, 32'b10111110001100001000110100111101,
        32'b00111110001100001000110100111101, 32'b00111111000001000110100111101111, 32'b00111111010111001011000010001101,
        32'b00111111100110100111101110010111, 32'b00111111110001101001111011100101, 32'b00111111111100101100001000110101,
        32'b01000000000011110111001011000011, 32'b01000000001001011000010001101001, 32'b01000000001110111001011000010001,
        32'b01000000010100011010011110111001, 32'b01000000011001111011100101100001, 32'b01000000011111011100101100001001,
        32'b01000000100010011110111001011001, 32'b01000000100101001111011100101101, 32'b01000000101000000000000000000000
    };

    InputFIFO #(
        .DATA_WIDTH(RAM_WIDTH),
        .ADDR_LINES(ADDR_LINES)
    ) dut (
        .clk_i(clk),
        .rstn_i(rstn_i),
        .wr_en_i(wr_en),
        .rd_en_i(rd_en),
        .data_i(data_i),
        .full_o(full_o),
        .empty_o(empty_o),
        .idle_o(idle_o),
        .data_o(data_o)
    );

    always #((CLK_PERIOD / 2)) clk = ~clk;

    initial begin
        $monitor("Time=%0t clk=%b rstn_i=%b wr_en=%b rd_en=%b data_i=%h data_o=%h full_o=%b empty_o=%b idle_o=%b",
                 $time, clk, rstn_i, wr_en, rd_en, data_i, data_o, full_o, empty_o, idle_o);
    end

    initial begin
        clk = 0;
        rstn_i = 0;
        wr_en = 0;
        rd_en = 0;
        data_i = 0;

        // Release reset
        #100;
        rstn_i = 1;

        // Test Case: Write the values from signal_sigmoid array into the FIFO
        for (int i = 0; i < 30; i = i + 1) begin
            if (!full_o) begin
                wr_en = 1;
                data_i = signal_sigmoid[i];
                #10; // Wait for a single cycle
            end
        end
        wr_en = 0;

        // Test Case: Read values from the FIFO until empty
        #10;
        while (!empty_o) begin
            @(posedge clk);
            rd_en = 1;
            @(posedge clk);
//            #20; // Wait for a single cycle
            rd_en = 0;
        end
        
//        rd_en = 1;
//        #10; // Wait for a single cycle
//        rd_en = 0;
        
//        #10;
        
//        rd_en = 1;
//        #10; // Wait for a single cycle
//        rd_en = 0;
        
        #10;
        $finish;
    end

endmodule
