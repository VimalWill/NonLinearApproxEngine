`timescale 1ns / 100ps

module TB_ROM;

    parameter CLK_PERIOD = 10;
    parameter RAM_WIDTH = 32;
    parameter ADDR_LINES = 5;
    parameter NUM_COEFFS = 26;

    reg clk_i;
    reg rd_en;
    reg redo_i;
    wire [RAM_WIDTH-1:0] data_o;

    // Expected values array (in order from index 0 to 25)
    reg [RAM_WIDTH-1:0] expected_values [0:25] = '{
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
        32'b00111111100000000000000000000000  // 0
    };

    CoeffROM #(
        .RAM_WIDTH(RAM_WIDTH),
        .ADDR_LINES(ADDR_LINES),
        .INIT_FILE("taylor_coeffs.mem")
    ) DUT (
        .clk_i(clk_i),
        .rd_en_i(rd_en),
        .reload_i(redo_i),
        .data_o(data_o)
    );

    always #(CLK_PERIOD/2) clk_i = ~clk_i;

    // Test stimulus
    integer i;
    integer errors;

    initial begin
        // Initialize signals
        clk_i = 1'b0;
        rd_en = 1'b0;
        redo_i = 1'b0;
        errors = 'b0;

        #(CLK_PERIOD*2);
        
        // Reset Pointer
        @(posedge clk_i);
        redo_i = 1;
        @(posedge clk_i);
        redo_i = 0;

        // Wait a few cycles
        #(CLK_PERIOD*2);

        // Test 1: Read all values sequentially with pulsed rd_en
        $display("Test 1: Sequential Read with Pulsed rd_en");
        for (i = 0; i < NUM_COEFFS; i = i + 1) begin
            @(posedge clk_i);
            rd_en = 1;
            @(posedge clk_i);
            rd_en = 0;

            // Wait for one additional cycle to allow data_o to stabilize
            @(posedge clk_i);

            if (data_o !== expected_values[i]) begin
                $display("Error at index %0d: Expected %h, Got %h", i, expected_values[i], data_o);
                errors = errors + 1;
            end
        end
        
        #(CLK_PERIOD*2);
        
        // Test 2: Test redo functionality
        $display("\nTest 2: Redo Operation");
        @(posedge clk_i);
        redo_i = 1;
        @(posedge clk_i);
        redo_i = 0;
        
        
        @(posedge clk_i);   // Wait for one additional cycle

        // Read first few values again with pulsed rd_en
        for (i = 0; i < 5; i = i + 1) begin
            rd_en = 1;
            @(posedge clk_i);
            rd_en = 0;
            
            
            @(posedge clk_i); // Wait for one additional cycle

            if (data_o !== expected_values[i]) begin
                $display("Error after redo at index %0d: Expected %h, Got %h", i, expected_values[i], data_o);
                errors = errors + 1;
            end
        end
        
        #(CLK_PERIOD*2);
        
        @(posedge clk_i);
        redo_i = 1;
        @(posedge clk_i);
        redo_i = 0;

        // Report results
        #(CLK_PERIOD*2);
        if (errors == 0)
            $display("\nAll tests passed successfully!");
        else
            $display("\nTests completed with %0d errors", errors);

        #(CLK_PERIOD*10);
        $finish;
    end

    initial begin
        $dumpfile("TB_ROM.vcd");
        $dumpvars(0, TB_ROM);
    end

endmodule
