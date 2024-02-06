`timescale 1ns/100ps

module mac_tb;

      // Parameters
      parameter WIDTH = 32;
      parameter DEPTH = 1;
    
      // Signals
      reg [31:0] signal_fifo;
      reg [31:0] coeff_fifo;
      reg clk;
      reg rst_n;
      wire [WIDTH-1:0] result;
      
    
      // Instantiate the MAC module
      mac #(WIDTH, DEPTH) dut (
        .signal_fifo(signal_fifo),
        .coeff_fifo(coeff_fifo),
        .clk(clk),
        .rst_n(rst_n),
        .result(result)
      );
    
      // Clock generation
      always #5 clk = ~clk;
    
      // Stimulus generation and result checking
      initial begin
        clk = 0;
        rst_n = 0;
        //signal_fifo = 32'd1;
        signal_fifo = 32'b01000001001101100000000000000000; //11.375
        coeff_fifo = 32'b01000000101100100000010000011001; //5.563
        #10 rst_n = 1;
    
        // Insert additional data into the FIFOs using a for loop
//        for (i = 0; i < DEPTH; i = i + 1) begin
//          #1;
//          signal_fifo = 32'b01000001001101100000000000000000; //11.375
//          #1;
//          coeff_fifo = 32'b01000000101100100000010000011001; //5.563
//        end
          
//        coeff_fifo = 8'h11;
//        #30 coeff_fifo = 8'h22;
//        #30 coeff_fifo = 8'h33;
//        #30 coeff_fifo = 8'h44;
    
        #500 $finish;
      end

endmodule
