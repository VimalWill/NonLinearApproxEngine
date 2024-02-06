`timescale 1ns/1ps

module fifo_tb;

    // Parameters
    parameter DATA_W = 8;
    parameter DEPTH  = 4;

    // Signals
    reg rst_n;
    reg push_i;
    reg [DATA_W-1:0] push_data_i;
    reg pop_i;
    wire [DATA_W-1:0] pop_data_o;
    wire full_o;
    wire empty_o;

    // Instantiate the qs_fifo module
    fifo #(DATA_W, DEPTH) uut (
        .rst_n(rst_n),
        .push_i(push_i),
        .push_data_i(push_data_i),
        .pop_i(pop_i),
        .pop_data_o(pop_data_o),
        .full_o(full_o),
        .empty_o(empty_o)
    );

    // Test stimulus
    initial begin
        rst_n = 0;
        push_i = 0;
        push_data_i = 0;
        pop_i = 0;

        // Reset
        #10 rst_n = 1;

//        // Push some data
//        #20 push_i = 1;
//        #20 push_data_i = 8'hAA;
//        #20 push_i = 0;

//        // Pop some data
//        #30 pop_i = 1;
//        #30 pop_i = 0;

//        // Push and Pop multiple times
//        #40 push_i = 1;
//        #40 push_data_i = 8'h55;
//        #40 push_i = 0;
//        #50 pop_i = 1;
//        #50 pop_i = 0;

         // Push data until full
         #10 push_i = 1;
         #10 push_data_i = 8'h11;
         #5 push_i = 0;
         #10 push_i = 1;
         #10 push_data_i = 8'h22;
         #5 push_i = 0;
         #10 push_i = 1;
         #10 push_data_i = 8'h33;
         #5 push_i = 0;
         #10 push_i = 1;
         #5 push_i = 0;

         // Pop data until empty
         #20 pop_i = 1;
         #20 pop_i = 0;
         #20 pop_i = 1;
         #20 pop_i = 0;
         #20 pop_i = 1;
         #20 pop_i = 0;
         #20 pop_i = 1;
         #20 pop_i = 0;
         #20 pop_i = 1;
         #20 pop_i = 0;
         #20 pop_i = 1;
         #20 pop_i = 0;
         #20 pop_i = 1;
         #20 pop_i = 0;
         #20 pop_i = 1;
         #20 pop_i = 0;
         #20 pop_i = 1;
         #20 pop_i = 0;
         #20 pop_i = 1;
         #20 pop_i = 0;
         
//         #10 push_i = 1;
//          push_data_i = 8'h44;
//         #5 push_i = 0;
//         #20 pop_i = 1;
//         #20 pop_i = 0;

         //Push and Pop with alternating patterns
//         #80 push_i = 1;
//         #80 push_data_i = 8'hAA;
//         #80 push_i = 0;
//         #90 pop_i = 1;
//         #90 pop_i = 0;
//         #100 push_i = 1;
//         #100 push_data_i = 8'h55;
//         #100 push_i = 0;
//         #110 pop_i = 1;
//         #110 pop_i = 0;

        #50 $finish; // Finish simulation after some time
    end

    // Dump waveform files
    initial begin
        $dumpfile("fifo_tb.vcd");
        $dumpvars(0, fifo_tb);
    end

endmodule