`timescale 1ns / 100ps

module mac #(

    parameter int DATA_WIDTH    = 32,
    parameter int ADDR_LINES    = 5
) (
    // Clock and reset
    input  logic                        clk_i,     // System clock
    input  logic                        rstn_i,   // Active-low async reset

    // Signal input interface
    input  logic [DATA_WIDTH-1:0]       signal_i,  // Input signal data
    input  logic                        wr_en_i,   // Write enable for signal FIFO
    input  logic                        last_i,    // Last signal indicator

    // Configuration
    input  logic [ADDR_LINES-1:0]       terms_i,   // Number of Taylor series terms

    // Status outputs
    output logic                        full_o,    // Signal FIFO full
    output logic                        empty_o,   // Signal FIFO empty
    output logic                        idle_o,    // Module is idle

    // Result output
    output logic [DATA_WIDTH-1:0]       result_o   // Computed result
);

    // Internal signals
    logic [DATA_WIDTH-1:0] signal_data, coeff_data;
    logic rd_en_signal, rd_en_coeff, load_result, dp_reset_o;
    logic add_valid, mul_valid, add_done, mul_done;
    logic [ADDR_LINES-1:0] coeff_addr;
    
    logic datapath_reset_n;
    assign datapath_reset_n = rstn_i & ~dp_reset_o;

    // Input FIFO for buffering signal data
    InputFIFO #(
        .DATA_WIDTH  (DATA_WIDTH),
        .ADDR_LINES  (ADDR_LINES)
    ) signal_fifo_inst (
        .clk_i      (clk_i),
        .rstn_i     (rstn_i),
        .full_o     (full_o),
        .empty_o    (empty_o),
        .idle_o     (idle_o),
        .wr_en_i    (wr_en_i),
        .rd_en_i    (rd_en_signal),
        .data_i     (signal_i),
        .data_o     (signal_data)
    );

    // Coefficient ROM containing Taylor series coefficients
    CoeffROM #(
        .DATA_WIDTH  (DATA_WIDTH),
        .ADDR_LINES  (ADDR_LINES),
        .INIT_FILE   ("taylor_coeffs.mem")
    ) coeff_rom_inst (
        .clk_i          (clk_i),
        .rd_en_i        (rd_en_coeff),
        .coeff_addr_i   (coeff_addr),
        .data_o         (coeff_data)
    );

    // Datapath for multiplication and accumulation
    datapath #(
        .DATA_WIDTH  (DATA_WIDTH)
    ) datapath_inst (
        .clk_i          (clk_i),
        .rstn_i         (datapath_reset_n),  // Use combined reset
        .signal_i       (signal_data),
        .coeff_i        (coeff_data),
        .load_result_i  (load_result),
        .add_valid_i    (add_valid),
        .mul_valid_i    (mul_valid),
        .add_done_o     (add_done),
        .mul_done_o     (mul_done),
        .result_o       (result_o)
    );
    
    // Control FSM
    controller #(
        .ADDR_LINES  (ADDR_LINES)
    ) controller_inst (
        .clk_i          (clk_i),
        .rstn_i         (rstn_i),
        .start_i        (last_i),
        .empty_i        (empty_o),
        .terms_i        (terms_i+1'd1),
        .mul_valid_i    (mul_valid),
        .mul_done_i     (mul_done),
        .add_valid_i    (add_valid),
        .add_done_i     (add_done),
        .rd_signal_o    (rd_en_signal),
        .rd_coeff_o     (rd_en_coeff),
        .load_result_o  (load_result),
        .coeff_addr_o   (coeff_addr),
        .dp_reset_o     (dp_reset_o)
    );

endmodule
