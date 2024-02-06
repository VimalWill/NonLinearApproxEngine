`timescale 1ns / 100ps

module fifo #(
    parameter DATA_W = 8,
    parameter DEPTH  = 4
    ) (
        input rst_n,
    
        input push_i,
        input [DATA_W-1:0] push_data_i,
    
        input pop_i,
        output [DATA_W-1:0] pop_data_o,
    
        output full_o,
        output empty_o
    );

    localparam PTR_W = $clog2(DEPTH);

    reg [DATA_W - 1:0] fifo_data_q [DEPTH-1:0];
    reg [PTR_W - 1:0] rd_ptr_q;
    reg [PTR_W - 1:0] wr_ptr_q;
    
    reg wrapped_rd_ptr_q;
    reg wrapped_wr_ptr_q;

    reg [DATA_W - 1:0] pop_data;

    wire empty;
    wire full;
    
    always @(posedge push_i, negedge rst_n) begin
        if (~rst_n) begin
            wr_ptr_q = {PTR_W{1'b0}};
            wrapped_wr_ptr_q = 1'b0;
        end
        else begin
            fifo_data_q[wr_ptr_q] = push_data_i;
            if (wr_ptr_q == DEPTH - 1) begin
                wr_ptr_q = {PTR_W{1'b0}};
                wrapped_wr_ptr_q = ~wrapped_wr_ptr_q;
            end else
                    wr_ptr_q = wr_ptr_q + 'b1;
        end
    end
    
    always @(posedge pop_i, negedge rst_n) begin
        if (~rst_n) begin
            rd_ptr_q = {PTR_W{1'b0}};
            wrapped_rd_ptr_q = 1'b0;
        end
        else begin
            pop_data = fifo_data_q[rd_ptr_q];
            if (rd_ptr_q == DEPTH - 1) begin
                rd_ptr_q = {PTR_W{1'b0}};
                wrapped_rd_ptr_q = ~wrapped_rd_ptr_q;
            end else
                    rd_ptr_q = rd_ptr_q + 'b1;
        end
    end

    // Empty
    assign empty = (rd_ptr_q == wr_ptr_q) & (wrapped_rd_ptr_q == wrapped_wr_ptr_q);
    // Full
    assign full  = (rd_ptr_q == wr_ptr_q) & (wrapped_rd_ptr_q != wrapped_wr_ptr_q);

    // Output assignments
    assign pop_data_o = pop_data;
    assign full_o = full;
    assign empty_o = empty;

endmodule