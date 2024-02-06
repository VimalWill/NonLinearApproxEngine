`timescale 1ns / 100ps

module testbench;

    reg clk;
    reg rst_n;
    wire LD_signal, LD_coeff;
    reg [31:0] signal, coeff;
    wire [31:0] result;
    wire rst_reg_n;

    datapath #(32) dut (
        .signal(signal),
        .coeff(coeff),
        .clk_n(clk),
        .rst_n(rst_reg_n),
        .LD_signal(LD_signal),
        .LD_coeff(LD_coeff),
        .result(result)
    );

    controller ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .rstc_n(rst_reg_n),
        .LD_signal(LD_signal),
        .LD_coeff(LD_coeff)
    );
    
    always #1 clk = ~clk;
    
    initial begin
        clk = 0;
        rst_n = 0;
        #10 rst_n = 1;
        
        #2
        coeff = 32'b01000000101100100000010000011001; //5.563
        signal = 32'b01000001001101100000000000000000; //11.375
        //signal = 32'b0;
        
        // Monitor the output
        $monitor("Time=%0t clk=%b rst_n=%b LD_signal=%b LD_coeff=%b  result=%b",
                 $time, clk, rst_n, LD_signal, LD_coeff, result);
        #60 $finish;
    end

endmodule