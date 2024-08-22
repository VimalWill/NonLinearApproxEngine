`timescale 1ns / 100ps

module controller #(
    parameter ADDR_LINES = 5
) (
    input wire clk_i,
    input wire rstn_i,

    input wire [ADDR_LINES-1:0] coeff_count,
    input wire start_signal,
    input wire start_coeff,

    output reg wr_en_signal,
    output reg rd_en_signal,
    output reg rd_en_coeff,

    output reg LD_result,

    output reg redo_coeff, redo_data
);

    reg [4:0] state, next_state;
    reg [ADDR_LINES - 1:0] count;
    reg [4:0] count2;

    localparam S0 = 5'b10000;
    localparam S1 = 5'b01000;
    localparam S2 = 5'b00100;
    localparam S3 = 5'b00010;
    localparam S4 = 5'b00001;

    always @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin

            count <= 'b0;
            count2 <= 'b0;

            state <= S0;
        end else begin
            if (state == S3) count <= count - 1;
            if (state == S0) count <= coeff_count;
            else if (state == S2) count2 <= 'b0;
            else if (state == S4) count2 <= count2 + 1;

            state <= next_state;
        end
    end

    always @(*) begin

        wr_en_signal = 1'b0;

        rd_en_signal = 1'b0;
        rd_en_coeff = 1'b0;

        LD_result = 1'b0;

        redo_coeff = 1'b0;
        redo_data = 1'b1;

        next_state = 'b0;

        case(state)
            S0: begin // Load Buffers

                if(start_signal & start_coeff) begin
                    rd_en_signal = 1'b1;
                    redo_coeff = 1'b1;

                    next_state = S1;
                end else
                    next_state = S0;
            end

            S1: begin
                redo_data = 1'b0;
                next_state = S2;
            end

            S2: begin

                if(count == 0) begin
                    LD_result = 1'b1;
                    next_state = S0;
                end else next_state = S3;
            end

            S3: begin
                rd_en_coeff = 1'b1;
                next_state = S4;
            end

            S4: begin
                if (count2 == 'd12) next_state = S2;
                else next_state = S4;
            end
            default : next_state = S0;
         endcase
     end
endmodule
