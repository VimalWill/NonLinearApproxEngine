`timescale 1ns / 100ps

module TB_datapath;
    parameter DATA_WIDTH = 32;
    
    reg clk;
    reg rstn_i;
    reg [DATA_WIDTH-1:0] signal, coeff;
    reg LD_result;
    reg add_valid;
    reg mul_valid;
    
    wire add_done, mul_done;
    wire [DATA_WIDTH-1:0] result;

    // Cycle counter variables
    integer cycle_count;
    integer total_cycles [0:2];  // Store cycles for each signal

    reg [DATA_WIDTH-1:0] signal_sigmoid [0:29] = {
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
        32'b00111111100000000000000000000000  // 0
    };
    
    datapath #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk_i(clk),
        .rstn_i(rstn_i),
        .signal_i(signal),
        .coeff_i(coeff),
        .load_result_i(LD_result),
        .add_valid_i(add_valid),
        .mul_valid_i(mul_valid),
        .add_done_o(add_done),
        .mul_done_o(mul_done),
        .result_o(result)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Tasks to generate single-cycle valid pulses
    task pulse_mul_valid;
        begin
            @(posedge clk);
            mul_valid = 1;
            @(posedge clk);
            mul_valid = 0;
        end
    endtask
    
    task pulse_add_valid;
        begin
            @(posedge clk);
            add_valid = 1;
            @(posedge clk);
            add_valid = 0;
        end
    endtask

    // Task for reset sequence
    task reset_sequence;
        begin
            @(posedge clk);
            rstn_i = 0;
            @(posedge clk);
            @(posedge clk);
            rstn_i = 1;
            @(posedge clk);
        end
    endtask

    initial begin
        // Initialize signals
        clk = 0;
        rstn_i = 1;
        LD_result = 0;
        add_valid = 0;
        mul_valid = 0;

        // Initial reset
        reset_sequence();

        // Process multiple signals
        for (int i = 0; i < 3; i = i + 1) begin
            cycle_count = 0;  // Reset counter for new signal
            
            // Load signal value
            @(posedge clk);
            signal = signal_sigmoid[i];
            cycle_count = cycle_count + 1;  // Count cycle for loading signal
            
            // Process coefficients 16-25
            for (int j = 16; j < 26; j = j + 1) begin
                // Load coefficient
                @(posedge clk);
                coeff = coeff_sigmoid[j];
                cycle_count = cycle_count + 1;  // Count cycle for loading coefficient
                
                // Multiplication operation
                pulse_mul_valid();
                cycle_count = cycle_count + 1;  // Count cycle for starting multiplication
                @(posedge mul_done);
                cycle_count = cycle_count + 1;  // Count cycle for multiplication completion
                @(posedge clk);
                
                // Addition operation
                pulse_add_valid();
                cycle_count = cycle_count + 1;  // Count cycle for starting addition
                @(posedge add_done);
                cycle_count = cycle_count + 1;  // Count cycle for addition completion
                @(posedge clk);
            end
            
            // Load final result
            @(posedge clk);
            LD_result = 1;
            @(posedge clk);
            LD_result = 0;
            cycle_count = cycle_count + 2;  // Count cycles for storing result
            
            // Store total cycles for this signal
            total_cycles[i] = cycle_count;
            $display("Signal %0d processed in %0d clock cycles", i, cycle_count);
            
            // Reset before next signal (not counting these cycles)
            if (i < 2) begin
                reset_sequence();
            end
        end
        
        // Display summary
        $display("\nProcessing Summary:");
        $display("Signal 0: %0d cycles", total_cycles[0]);
        $display("Signal 1: %0d cycles", total_cycles[1]);
        $display("Signal 2: %0d cycles", total_cycles[2]);
        $display("Average cycles per signal: %0d", (total_cycles[0] + total_cycles[1] + total_cycles[2])/3);
        
        repeat(10) @(posedge clk);
        $finish;
    end
    
    initial $monitor("Time=%0t result=%h", $time, result);

endmodule