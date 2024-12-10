//`timescale 1ns / 100ps

//module controller #(
//    parameter int ADDR_LINES = 5
//) (
//    // Clock and reset
//    input  logic                    clk_i,
//    input  logic                    rstn_i,

//    // Control inputs
//    input  logic                    start_i,    // last_i from top
//    input  logic                    empty_i,    // FIFO empty status
//    input  logic [ADDR_LINES-1:0]   terms_i,    // Number of terms to process

//    // Datapath handshaking
//    input  logic                    mul_done_i,
//    input  logic                    add_done_i,
//    output logic                    mul_valid_i, // To datapath
//    output logic                    add_valid_i, // To datapath
//    output logic                    dp_reset_o,  // Reset signal to datapath

//    // Memory interface
//    output logic                    rd_signal_o,   // FIFO read enable
//    output logic                    rd_coeff_o,    // ROM read enable
//    output logic                    load_result_o, // Load result to output register
//    output logic [ADDR_LINES-1:0]   coeff_addr_o   // Address for coefficient ROM
//);

//    // State encoding
//    typedef enum logic [3:0] {
//        IDLE,
//        RESET_DATAPATH,  // New state
//        LOAD_SIGNAL,
//        LOAD_COEFF,
//        MULTIPLY,
//        WAIT_MUL,
//        ADD,
//        WAIT_ADD,
//        CHECK_TERMS,
//        STORE_RESULT
//    } state_t;

//    logic reload_o;

//    // State registers
//    state_t current_state, next_state;

//    // Term counter
//    logic [ADDR_LINES-1:0] term_count;
//    logic [ADDR_LINES-1:0] term_count_next;

//    // State register
//    always_ff @(posedge clk_i or negedge rstn_i) begin
//        if (!rstn_i) begin
//            current_state <= IDLE;
//            term_count <= '0;
//        end else begin
//            current_state <= next_state;
//            term_count <= term_count_next;
//        end
//    end

//    // Coefficient address generation - down counter
//    always_comb begin
//        if (!rstn_i || reload_o) begin
//            coeff_addr_o = terms_i - 1;
//        end else begin
//            coeff_addr_o = terms_i - 1 - term_count;
//        end
//    end

//    // Next state and output logic
//    always_comb begin
//        // Default assignments
//        next_state = current_state;
//        term_count_next = term_count;
//        mul_valid_i = 1'b0;
//        add_valid_i = 1'b0;
//        rd_signal_o = 1'b0;
//        rd_coeff_o = 1'b0;
//        reload_o = 1'b0;
//        load_result_o = 1'b0;
//        dp_reset_o = 1'b0;

//        case (current_state)
//            IDLE: begin
//                term_count_next = '0;
//                reload_o = 1'b1;
//                if (start_i) begin
//                    next_state = RESET_DATAPATH;
//                end
//            end

//            RESET_DATAPATH: begin
//                dp_reset_o = 1'b1;  // Reset datapath for one cycle
//                next_state = LOAD_SIGNAL;
//            end

//            LOAD_SIGNAL: begin
//                rd_signal_o = 1'b1;
//                next_state = LOAD_COEFF;
//            end

//            LOAD_COEFF: begin
//                rd_coeff_o = 1'b1;
//                next_state = MULTIPLY;
//            end

//            MULTIPLY: begin
//                mul_valid_i = 1'b1;
//                next_state = WAIT_MUL;
//            end

//            WAIT_MUL: begin
//                if (mul_done_i) begin
//                    next_state = ADD;
//                end
//            end

//            ADD: begin
//                add_valid_i = 1'b1;
//                next_state = WAIT_ADD;
//            end

//            WAIT_ADD: begin
//                if (add_done_i) begin
//                    next_state = CHECK_TERMS;
//                end
//            end

//            CHECK_TERMS: begin
//                if (term_count < terms_i - 1) begin
//                    term_count_next = term_count + 1'b1;
//                    next_state = LOAD_COEFF;
//                end else begin
//                    next_state = STORE_RESULT;
//                end
//            end

//            STORE_RESULT: begin
//                load_result_o = 1'b1;
//                if (start_i) begin
//                    next_state = IDLE;
//                end else if (!empty_i) begin
//                    reload_o = 1'b1;
//                    term_count_next = '0;
//                    next_state = RESET_DATAPATH;  // Go to reset state instead of LOAD_SIGNAL
//                end else begin
//                    next_state = IDLE;
//                end
//            end

//            default: begin
//                next_state = IDLE;
//            end
//        endcase
//    end

//endmodule

`timescale 1ns / 100ps

module controller #(
    parameter int ADDR_LINES = 5
) (
    // Clock and reset
    input  logic                    clk_i,
    input  logic                    rstn_i,

    // Control inputs
    input  logic                    start_i,    // last_i from top
    input  logic                    empty_i,    // FIFO empty status
    input  logic [ADDR_LINES-1:0]   terms_i,    // Number of terms to process

    // Datapath handshaking
    input  logic                    mul_done_i,
    input  logic                    add_done_i,
    output logic                    mul_valid_i, // To datapath
    output logic                    add_valid_i, // To datapath
    output logic                    dp_reset_o,  // Reset signal to datapath

    // Memory interface
    output logic                    rd_signal_o,   // FIFO read enable
    output logic                    rd_coeff_o,    // ROM read enable
    output logic                    load_result_o, // Load result to output register
    output logic [ADDR_LINES-1:0]   coeff_addr_o,  // Address for coefficient ROM

    // New output port
    output logic                    done_o         // Indicates completion of operation for a single input
);

    // State encoding
    typedef enum logic [3:0] {
        IDLE,
        RESET_DATAPATH,
        LOAD_SIGNAL,
        LOAD_COEFF,
        MULTIPLY,
        WAIT_MUL,
        ADD,
        WAIT_ADD,
        CHECK_TERMS,
        STORE_RESULT
    } state_t;

    logic reload_o;

    // State registers
    state_t current_state, next_state;

    // Term counter
    logic [ADDR_LINES-1:0] term_count;
    logic [ADDR_LINES-1:0] term_count_next;

    // Done signal
    logic done_comb;
    logic [4:0] done_shift_reg;

    // State register
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            current_state <= IDLE;
            term_count <= '0;
            done_shift_reg <= 5'b0;
        end else begin
            current_state <= next_state;
            term_count <= term_count_next;
            done_shift_reg <= {done_shift_reg[3:0], done_comb};
        end
    end

    // Assign done_o to the last bit of the shift register
    assign done_o = done_shift_reg[4];

    // Coefficient address generation - down counter
    always_comb begin
        if (!rstn_i || reload_o) begin
            coeff_addr_o = terms_i - 1;
        end else begin
            coeff_addr_o = terms_i - 1 - term_count;
        end
    end

    // Next state and output logic
    always_comb begin
        // Default assignments
        next_state = current_state;
        term_count_next = term_count;
        mul_valid_i = 1'b0;
        add_valid_i = 1'b0;
        rd_signal_o = 1'b0;
        rd_coeff_o = 1'b0;
        reload_o = 1'b0;
        load_result_o = 1'b0;
        dp_reset_o = 1'b0;
        done_comb = 1'b0;  // Default assignment for the done signal

        case (current_state)
            IDLE: begin
                term_count_next = '0;
                reload_o = 1'b1;
                if (start_i) begin
                    next_state = RESET_DATAPATH;
                end
            end

            RESET_DATAPATH: begin
                dp_reset_o = 1'b1;  // Reset datapath for one cycle
                next_state = LOAD_SIGNAL;
            end

            LOAD_SIGNAL: begin
                rd_signal_o = 1'b1;
                next_state = LOAD_COEFF;
            end

            LOAD_COEFF: begin
                rd_coeff_o = 1'b1;
                next_state = MULTIPLY;
            end

            MULTIPLY: begin
                mul_valid_i = 1'b1;
                next_state = WAIT_MUL;
            end

            WAIT_MUL: begin
                if (mul_done_i) begin
                    next_state = ADD;
                end
            end

            ADD: begin
                add_valid_i = 1'b1;
                next_state = WAIT_ADD;
            end

            WAIT_ADD: begin
                if (add_done_i) begin
                    next_state = CHECK_TERMS;
                end
            end

            CHECK_TERMS: begin
                if (term_count < terms_i - 1) begin
                    term_count_next = term_count + 1'b1;
                    next_state = LOAD_COEFF;
                end else begin
                    next_state = STORE_RESULT;
                end
            end

            STORE_RESULT: begin
                load_result_o = 1'b1;
//                done_comb = 1'b1;
                if (start_i) begin
                    next_state = IDLE;
                end else if (!empty_i) begin
                    reload_o = 1'b1;
                    term_count_next = '0;
                    done_comb = 1'b1;
                    next_state = RESET_DATAPATH;
                end else begin
                    next_state = IDLE;
                    done_comb = 1'b1;  // Set done_comb high when transitioning to IDLE
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule