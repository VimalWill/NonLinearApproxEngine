`timescale 1ns / 100ps

module sigmoid;

    parameter DATA_WIDTH = 32;
    parameter ADDR_LINES = 5;
    
    reg clk_i, rstn_i;
    reg [DATA_WIDTH - 1:0] signal_fifo;
    reg [DATA_WIDTH - 1:0] coeff_fifo;
    
    // Outputs
    wire full_adder, full_mul;
    wire empty_adder, empty_mul;
    wire [DATA_WIDTH - 1:0] result;
    
    mac #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_LINES(ADDR_LINES)
    ) dut (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .signal_fifo(signal_fifo),
        .coeff_fifo(coeff_fifo),
        .full_adder(full_adder),
        .empty_adder(empty_adder),
        .full_mul(full_mul),
        .empty_mul(empty_mul),
        .result(result)
    );
    
    // Clock generation
    always #5 clk_i = ~clk_i;
    
    //initial $monitor("Time=%0t, result-hex=%h, result=%b", $time, result, result);

    initial begin
        clk_i = 0;
        rstn_i = 0;

        #10
        rstn_i = 1;
        #10

        // Sigmoid
        signal_fifo = 32'b11000000101000000000000000000000;
        #10;
        signal_fifo = 32'b11000000100101001111011100101101;
        #10;
        signal_fifo = 32'b11000000100010011110111001011001;
        #10;
        signal_fifo = 32'b11000000011111011100101100001001;
        #10;
        signal_fifo = 32'b11000000011001111011100101100001;
        #10;
        signal_fifo = 32'b11000000010100011010011110111001;
        #10;
        signal_fifo = 32'b11000000001110111001011000010001;
        #10;
        signal_fifo = 32'b11000000001001011000010001101001;
        #10;
        signal_fifo = 32'b11000000000011110111001011000011;
        #10;
        signal_fifo = 32'b10111111111100101100001000110101;
        #10;
        signal_fifo = 32'b10111111110001101001111011100101;
        #10;
        signal_fifo = 32'b10111111100110100111101110010111;
        #10;
        signal_fifo = 32'b10111111010111001011000010001101;
        #10;
        signal_fifo = 32'b10111111000001000110100111101111;
        #10;
        signal_fifo = 32'b10111110001100001000110100111101;
        #10;
        signal_fifo = 32'b00111110001100001000110100111101;
        #10;
        signal_fifo = 32'b00111111000001000110100111101111;
        #10;
        signal_fifo = 32'b00111111010111001011000010001101;
        #10;
        signal_fifo = 32'b00111111100110100111101110010111;
        #10;
        signal_fifo = 32'b00111111110001101001111011100101;
        #10;
        signal_fifo = 32'b00111111111100101100001000110101;
        #10;
        signal_fifo = 32'b01000000000011110111001011000011;
        #10;
        signal_fifo = 32'b01000000001001011000010001101001;
        #10;
        signal_fifo = 32'b01000000001110111001011000010001;
        #10;
        signal_fifo = 32'b01000000010100011010011110111001;
        #10;
        signal_fifo = 32'b01000000011001111011100101100001;
        #10;
        signal_fifo = 32'b01000000011111011100101100001001;
        #10;
        signal_fifo = 32'b01000000100010011110111001011001;
        #10;
        signal_fifo = 32'b01000000100101001111011100101101;
        #10;
        signal_fifo = 32'b01000000101000000000000000000000;
        #10;
        signal_fifo = 32'b01111111100100000000000000000000; //NaN
        #10;


        coeff_fifo = 32'b00010101100111111001111001100111;
        #10;
        coeff_fifo = 32'b00010111111110010110011110000001;
        #10;
        coeff_fifo = 32'b00011010001110110000110110100001;
        #10;
        coeff_fifo = 32'b00011100100001100111000111001011;
        #10;
        coeff_fifo = 32'b00011110101110001101110001110111;
        #10;
        coeff_fifo = 32'b00100000111100101010000101011101;
        #10;
        coeff_fifo = 32'b00100011000101111010010011011011;
        #10;
        coeff_fifo = 32'b00100101001101000001001111000011;
        #10;
        coeff_fifo = 32'b00100111010010101001011000111011;
        #10;
        coeff_fifo = 32'b00101001010101110011111110011111;
        #10;
        coeff_fifo = 32'b00101011010101110011111110011111;
        #10;
        coeff_fifo = 32'b00101101010010011100101110100101;
        #10;
        coeff_fifo = 32'b00101111001100001001001000110001;
        #10;
        coeff_fifo = 32'b00110001000011110111011011000111;
        #10;
        coeff_fifo = 32'b00110010110101110011001000101011;
        #10;
        coeff_fifo = 32'b00110100100100111111001001111101;
        #10;
        coeff_fifo = 32'b00110110001110001110111100011101;
        #10;
        coeff_fifo = 32'b00110111110100000000110100000001;
        #10;
        coeff_fifo = 32'b00111001010100000000110100000001;
        #10;
        coeff_fifo = 32'b00111010101101100000101101100001;
        #10;
        coeff_fifo = 32'b00111100000010001000100010001001;
        #10;
        coeff_fifo = 32'b00111101001010101010101010101011;
        #10;
        coeff_fifo = 32'b00111110001010101010101010101011;
        #10;
        coeff_fifo = 32'b00111111000000000000000000000000;
        #10;
        coeff_fifo = 32'b00111111100000000000000000000000;
        #10;
        coeff_fifo = 32'b00111111100000000000000000000000;
        #10;
        coeff_fifo = 32'b01111111100100000000000000000000; //NaN
        #10;
                
        #3500 $finish;
    end
    initial $monitor("Time=%0t, result-hex=%h, result=%b", $time, result, result);
endmodule