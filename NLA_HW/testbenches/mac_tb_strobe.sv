`timescale 1ns / 100ps

module mac_tb_strobe;

    parameter DATA_WIDTH = 32;
    parameter ADDR_LINES = 5;

    reg clk_i, rstn_i;
    reg [DATA_WIDTH - 1:0] signal_fifo;
    reg [DATA_WIDTH - 1:0] coeff_fifo;
    reg [ADDR_LINES-1:0] taylor_length;

    // Outputs
    wire full_adder, full_mul;
    wire empty_adder, empty_mul;
    wire [DATA_WIDTH - 1:0] result;

    reg [DATA_WIDTH-1:0] signal_sigmoid [0:30] = {
        32'b11000000101000000000000000000000,
        32'b11000000100101001111011100101101,
        32'b11000000100010011110111001011001,
        32'b11000000011111011100101100001001,
        32'b11000000011001111011100101100001,
        32'b11000000010100011010011110111001,
        32'b11000000001110111001011000010001,
        32'b11000000001001011000010001101001,
        32'b11000000000011110111001011000011,
        32'b10111111111100101100001000110101,
        32'b10111111110001101001111011100101,
        32'b10111111100110100111101110010111,
        32'b10111111010111001011000010001101,
        32'b10111111000001000110100111101111,
        32'b10111110001100001000110100111101,
        32'b00111110001100001000110100111101,
        32'b00111111000001000110100111101111,
        32'b00111111010111001011000010001101,
        32'b00111111100110100111101110010111,
        32'b00111111110001101001111011100101,
        32'b00111111111100101100001000110101,
        32'b01000000000011110111001011000011,
        32'b01000000001001011000010001101001,
        32'b01000000001110111001011000010001,
        32'b01000000010100011010011110111001,
        32'b01000000011001111011100101100001,
        32'b01000000011111011100101100001001,
        32'b01000000100010011110111001011001,
        32'b01000000100101001111011100101101,
        32'b01000000101000000000000000000000,
        32'b01111111100100000000000000000000  // NaN
    };

    reg [DATA_WIDTH - 1:0] signal_GeLu [0:29] = {
        32'b11000001000010000010100011110101,
        32'b11000000111111011000101000010001,
        32'b11000000111010101100001000110101,
        32'b11000000110101111111101001011001,
        32'b11000000110001010011001001111111,
        32'b11000000101100100110101010100011,
        32'b11000000100111111010001011000111,
        32'b11000000100011001101101011101101,
        32'b11000000011101000010011000100011,
        32'b11000000010011101001011001101101,
        32'b11000000001010010000011010110101,
        32'b11000000000000110111011011111111,
        32'b10111111101110111100111010010001,
        32'b10111111011000010101111001000111,
        32'b10111110100101100011111011011011,
        32'b00111110100101100011111011011011,
        32'b00111111011000010101111001000111,
        32'b00111111101110111100111010010001,
        32'b01000000000000110111011011111111,
        32'b01000000001010010000011010110101,
        32'b01000000010011101001011001101101,
        32'b01000000100011001101101011101101,
        32'b01000000100111111010001011000111,
        32'b01000000101100100110101010100011,
        32'b01000000110001010011001001111111,
        32'b01000000110101111111101001011001,
        32'b01000000111010101100001000110101,
        32'b01000000111111011000101000010001,
        32'b01000001000010000010100011110101,
        32'b01111111100100000000000000000000  // NaN
    };

    reg [DATA_WIDTH - 1:0] coeff_sigmoid [0:25] = {
        32'b00010101100111111001111001100111, // 25
        32'b00010111111110010110011110000001, // 24
        32'b00011010001110110000110110100001, // 23
        32'b00011100100001100111000111001011, // 22
        32'b00011110101110001101110001110111, // 21
        32'b00100000111100101010000101011101, // 20
        32'b00100011000101111010010011011011, // 19
        32'b00100101001101000001001111000011, // 18
        32'b00100111010010101001011000111011, // 17
        32'b00101001010101110011111110011111, // 16
        32'b00101011010101110011111110011111, // 15
        32'b00101101010010011100101110100101, // 14
        32'b00101111001100001001001000110001, // 13
        32'b00110001000011110111011011000111, // 12
        32'b00110010110101110011001000101011, // 11
        32'b00110100100100111111001001111101, // 10
        32'b00110110001110001110111100011101, // 9
        32'b00110111110100000000110100000001, // 8
        32'b00111001010100000000110100000001, // 7
        32'b00111010101101100000101101100001, // 6
        32'b00111100000010001000100010001001, // 5
        32'b00111101001010101010101010101011, // 4
        32'b00111110001010101010101010101011, // 3
        32'b00111111000000000000000000000000, // 2
        32'b00111111100000000000000000000000, // 1
        32'b01111111100100000000000000000000  // NaN
    };

    reg [DATA_WIDTH - 1:0] coeff_TanH [0:31] = {
        32'b00011000100111001001100101100011, // 30
        32'b00011010100100101100111111001101, // 29
        32'b00011100100001010000110001010001, // 28
        32'b00011110011010001101010110001111, // 27
        32'b00100000010001000111010000101111, // 26
        32'b00100010000111111001111001100111, // 25
        32'b00100011111110010110011110000001, // 24
        32'b00100101101110110000110110100001, // 23
        32'b00100111100001100111000111001011, // 22
        32'b00101001001110001101110001110111, // 21
        32'b00101010111100101010000101011101, // 20
        32'b00101100100101111010010011011011, // 19
        32'b00101110001101000001001111000011, // 18
        32'b00101111110010101001011000111011, // 17
        32'b00110001010101110011111110011111, // 16
        32'b00110010110101110011111110011111, // 15
        32'b00110100010010011100101110100101, // 14
        32'b00110101101100001001001000110001, // 13
        32'b00110111000011110111011011000111, // 12
        32'b00111000010101110011001000101011, // 11
        32'b00111001100100111111001001111101, // 10
        32'b00111010101110001110111100011101, // 9
        32'b00111011110100000000110100000001, // 8
        32'b00111100110100000000110100000001, // 7
        32'b00111101101101100000101101100001, // 6
        32'b00111110100010001000100010001001, // 5
        32'b00111111001010101010101010101011, // 4
        32'b00111111101010101010101010101011, // 3
        32'b01000000000000000000000000000000, // 2
        32'b01000000000000000000000000000000, // 1
        32'b00111111100000000000000000000000, // 0
        32'b01111111100100000000000000000000  // NaN
    };

    mac #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_LINES(ADDR_LINES)
    ) dut (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .signal_fifo(signal_fifo),
        .coeff_fifo(coeff_fifo),
        .taylor_length(taylor_length),
        .full_adder(full_adder),
        .empty_adder(empty_adder),
        .full_mul(full_mul),
        .empty_mul(empty_mul),
        .result(result)
    );
    
    always #5 clk_i = ~clk_i;
    
    initial begin
        clk_i = 0;
        rstn_i = 1;
        taylor_length = 5'd30;

        rstn_i = 0;
        #10;
        rstn_i = 1;
    end
    
    initial begin
        #10;
        for (int i = 0; i < 31; i = i + 1) begin
            signal_fifo = signal_sigmoid[i];
            #10;
        end
        
//        signal_fifo = signal_sigmoid[0];
//        #10;
//        signal_fifo = signal_sigmoid[30];
//        #10;
    end
    
    initial begin
        #10;
        for (int i = 0; i < 32; i = i + 1) begin
            coeff_fifo = coeff_TanH[i];
            #10;
        end
    end
    
    initial begin 
        $monitor("Time=%0t, result-hex=%h, result=%b", $time, result, result);
        #150000 $finish;
//        #19000 $finish;
//        #5000 $finish;
//        #350 $finish;
    end    
endmodule
