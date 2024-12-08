module TB_mac;
    parameter DATA_WIDTH = 32;
    parameter ADDR_LINES = 5;

    // Original signals
    reg clk;
    reg rstn_i;
    reg [DATA_WIDTH-1:0] signal_i;
    reg wr_en_i;
    reg last_i;
    reg [ADDR_LINES-1:0] terms_i;
    wire full_o;
    wire empty_o;
    wire idle_o;
    wire [DATA_WIDTH-1:0] result_o;
    reg [DATA_WIDTH-1:0] last_valid_result;
    reg result_valid;
    integer processed_signals;

    // New cycle counting signals
    integer cycle_counter;              // Global cycle counter
    integer signal_process_cycles;      // Cycles for current signal processing
    integer fifo_write_cycles;         // Cycles spent writing to FIFO
    integer total_fifo_write_cycles;   // Total cycles spent in FIFO writes

    // State cycle counters
    integer idle_state_cycles;
    integer load_state_cycles;
    integer compute_state_cycles;
    integer store_state_cycles;

    // Arrays to store per-signal statistics
    integer signal_processing_times[0:29];  // Store processing time for each signal

    // Signal to track start of processing
    reg processing_started;
    reg writing_to_fifo;

    // Test data storage
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

    reg [DATA_WIDTH-1:0] signal_tanh [0:29] = {
        32'b11000001001000000000000000000000, 32'b11000001000101001111011100101101, 32'b11000001000010011110111001011001,
        32'b11000000111111011100101100001001, 32'b11000000111001111011100101100001, 32'b11000000110100011010011110111001,
        32'b11000000101110111001011000010001, 32'b11000000101001011000010001101001, 32'b11000000100011110111001011000011,
        32'b11000000011100101100001000110101, 32'b11000000010001101001111011100101, 32'b11000000000110100111101110010111,
        32'b10111111110111001011000010001101, 32'b10111111100001000110100111101111, 32'b10111110101100001000110100111101,
        32'b00111110101100001000110100111101, 32'b00111111100001000110100111101111, 32'b00111111110111001011000010001101,
        32'b01000000000110100111101110010111, 32'b01000000010001101001111011100101, 32'b01000000011100101100001000110101,
        32'b01000000100011110111001011000011, 32'b01000000101001011000010001101001, 32'b01000000101110111001011000010001,
        32'b01000000110100011010011110111001, 32'b01000000111001111011100101100001, 32'b01000000111111011100101100001001,
        32'b01000001000010011110111001011001, 32'b01000001000101001111011100101101, 32'b01000001001000000000000000000000
    };

    reg [ADDR_LINES-1:0] num_sig;

    // Test phases
    typedef enum {RESET, LOAD_SIGNALS, WAIT_PROCESSING, DONE} test_phase_t;
    test_phase_t current_phase;

    // Internal signals to monitor
    wire load_result;

    // Instantiate DUT
    mac #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_LINES(ADDR_LINES)
    ) dut (
        .clk_i(clk),
        .rstn_i(rstn_i),
        .signal_i(signal_i),
        .wr_en_i(wr_en_i),
        .last_i(last_i),
        .terms_i(terms_i),
        .full_o(full_o),
        .empty_o(empty_o),
        .idle_o(idle_o),
        .result_o(result_o)
    );

    assign load_result = dut.controller_inst.load_result_o;

    // Clock generation
    always #5 clk = ~clk;

    // Task for reset sequence
    task reset_sequence;
        begin
            rstn_i = 0;
            wr_en_i = 0;
            last_i = 0;
            @(posedge clk);
            @(posedge clk);
            rstn_i = 1;
            @(posedge clk);
        end
    endtask

    // Task to write signal to FIFO
    task write_signal;
        input [DATA_WIDTH-1:0] sig_data;
        input last;
        begin
            wait(!full_o);  // Wait if FIFO is full
            @(posedge clk);
            signal_i = sig_data;
            wr_en_i = 1;
            last_i = last;
            @(posedge clk);
            wr_en_i = 0;
            last_i = 0;
        end
    endtask

    // Global cycle counter
    always @(posedge clk) begin
        if (!rstn_i)
            cycle_counter <= 0;
        else
            cycle_counter <= cycle_counter + 1;
    end

    // Monitor state cycles
    always @(posedge clk) begin
        if (!rstn_i) begin
            idle_state_cycles <= 0;
            load_state_cycles <= 0;
            compute_state_cycles <= 0;
            store_state_cycles <= 0;
        end
        else begin
            case (dut.controller_inst.current_state)
                3'b000: idle_state_cycles <= idle_state_cycles + 1;    // IDLE
                3'b001: load_state_cycles <= load_state_cycles + 1;    // LOAD
                3'b010: compute_state_cycles <= compute_state_cycles + 1; // COMPUTE
                3'b011: store_state_cycles <= store_state_cycles + 1;    // STORE
            endcase
        end
    end

    // Monitor signal processing time
    always @(posedge clk) begin
        if (!rstn_i) begin
            signal_process_cycles <= 0;
            processing_started <= 0;
        end
        else begin
            if (dut.controller_inst.current_state == 3'b001 && !processing_started) begin
                // Start counting when entering LOAD state
                signal_process_cycles <= 0;
                processing_started <= 1;
            end
            else if (processing_started) begin
                signal_process_cycles <= signal_process_cycles + 1;
                if (load_result) begin
                    // Store the cycle count for this signal
                    signal_processing_times[processed_signals] <= signal_process_cycles;
                    processing_started <= 0;
                end
            end
        end
    end

    // Monitor FIFO write cycles
    reg waiting_for_fifo;
    always @(posedge clk) begin
        if (!rstn_i) begin
            fifo_write_cycles <= 0;
            total_fifo_write_cycles <= 0;
            writing_to_fifo <= 0;
            waiting_for_fifo <= 0;
        end
        else begin
            // Start counting when we begin waiting for FIFO space
            if (current_phase == LOAD_SIGNALS && !waiting_for_fifo && !writing_to_fifo) begin
                waiting_for_fifo <= 1;
                fifo_write_cycles <= 0;
            end
            // Count cycles while waiting for FIFO and during write
            if (waiting_for_fifo || writing_to_fifo) begin
                fifo_write_cycles <= fifo_write_cycles + 1;
            end
            // When write begins
            if (wr_en_i) begin
                waiting_for_fifo <= 0;
                writing_to_fifo <= 1;
            end
            // When write completes
            if (writing_to_fifo && !wr_en_i) begin
                writing_to_fifo <= 0;
                total_fifo_write_cycles <= total_fifo_write_cycles + fifo_write_cycles;
            end
        end
    end

    // Main test sequence
    initial begin
        // Initialize signals
        clk = 0;
        processed_signals = 0;
        result_valid = 0;
        current_phase = RESET;
        terms_i = 30;
        num_sig = 3;

        // Initialize cycle counters
        cycle_counter = 0;
        signal_process_cycles = 0;
        fifo_write_cycles = 0;
        total_fifo_write_cycles = 0;
        idle_state_cycles = 0;
        load_state_cycles = 0;
        compute_state_cycles = 0;
        store_state_cycles = 0;

        // Reset sequence
        reset_sequence();

        // Start test sequence
        current_phase = LOAD_SIGNALS;

        // Write signals
        for (int i = 0; i < num_sig; i++) begin
            write_signal(signal_tanh[i], (i == (num_sig-1)));  // Last flag only on final signal
        end

        current_phase = WAIT_PROCESSING;

        // Wait for all signals to be processed
        while (processed_signals < num_sig) begin
            @(posedge clk);
            if (load_result) begin  // Detect completion of one signal processing
                @(posedge clk);
                processed_signals++;
                last_valid_result = result_o;
                result_valid = 1;
                $display("Time=%0t: Signal %0d processed, Result = %h, Processing cycles = %0d",
                        $time, processed_signals-1, result_o, signal_processing_times[processed_signals-1]);
                @(posedge clk);
                result_valid = 0;
            end
        end

        // Display final statistics
        $display("\nTest Summary:");
        $display("Total signals processed: %0d", processed_signals);
        $display("Total clock cycles: %0d", cycle_counter);
        $display("Total FIFO write cycles: %0d", total_fifo_write_cycles);
        $display("Average FIFO write cycles per signal: %0d", total_fifo_write_cycles/num_sig);
        $display("\nState Cycle Distribution:");
        $display("IDLE state cycles: %0d", idle_state_cycles);
        $display("LOAD state cycles: %0d", load_state_cycles);
        $display("COMPUTE state cycles: %0d", compute_state_cycles);
        $display("STORE state cycles: %0d", store_state_cycles);

        $display("\nPer-Signal Processing Times:");
        for (int i = 0; i < num_sig; i++) begin
            $display("Signal %0d: %0d cycles", i, signal_processing_times[i]);
        end

        current_phase = DONE;
        #100 $finish;
    end

    // Monitor
    always @(posedge clk) begin
        case (current_phase)
            RESET:
                $display("Time=%0t: Reset phase", $time);

            LOAD_SIGNALS: begin
                if (wr_en_i)
                    $display("Time=%0t: Writing signal = %h", $time, signal_i);
            end

            WAIT_PROCESSING: begin
                if (load_result)
                    $display("Time=%0t: Processing complete for signal %0d",
                            $time, processed_signals);
            end

            DONE:
                $display("Time=%0t: Test completed", $time);
        endcase
    end

    // Assertions
    property fifo_full_write;
        @(posedge clk) full_o |-> !wr_en_i;
    endproperty
    assert property (fifo_full_write) else $error("Writing to full FIFO!");

    property valid_load_result;
        @(posedge clk) load_result |-> $stable(result_o);
    endproperty
    assert property (valid_load_result) else $error("Result changed during load_result!");

    // Timeout watchdog
    initial begin
        #1000000 $error("Testbench timeout!");
        $finish;
    end

    // Waveform dumping
    initial begin
        $dumpfile("tb_mac.vcd");
        $dumpvars(0, TB_mac);
    end

endmodule
