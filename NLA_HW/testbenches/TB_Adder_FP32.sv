`timescale 1ns / 100ps

module TB_Adder_FP32;

    parameter DATA_WIDTH = 32;

    reg clk_n, rst_n, valid_i;
    reg [DATA_WIDTH-1:0] A, B;
    wire [DATA_WIDTH-1:0] Result, Result_og;
    wire done_o;

    reg [DATA_WIDTH-1:0] A_values [0:13] = {
        32'b0,
        32'h3638ef1d, 32'h3ab60b61, 32'h2317a4db,
        32'h3638ef1d, 32'hAB573F9F, 32'h2f309231,
        32'h32d7322b, 32'h3638ef1d, 32'h39500d01,
        32'h3c088889, 32'h3e2aaaab, 32'h3f800000,
        32'h37d00d01
    };

    reg [DATA_WIDTH-1:0] B_values [0:13] = {
        32'b0,
        32'hb5b8ef1c, 32'h3b0b8362, 32'b0,
        32'hb3121ee6, 32'h298c8b2a, 32'h2d9a701d,
        32'h3175ba87, 32'h35101ffb, 32'h3868a920,
        32'h3b6a3241, 32'h3df3b36a, 32'h3f988d00,
        32'h37d8cdf6
    };

    Adder_32 uut1 (
        .clkn_i(clk_n),
        .rstn_i(rst_n),
        .valid_i(valid_i),
        .A(A),
        .B(B),
        .Result(Result),
        .done_o(done_o)
    );

    OG_Adder_32 uut2 (
        .clk_n(clk_n),
        .rst_n(rst_n),
        .A(A),
        .B(B),
        .Result(Result_og)
    );

    always #1 clk_n = ~clk_n;
    
    initial begin
        clk_n = 1'b0;
        rst_n = 1'b1;
        valid_i = 1'b0;
        
        // Reset
        #2 rst_n = 1'b0;
        #4 rst_n = 1'b1;
        
        // Wait a few cycles after reset
        #4;
        
        // Run test vectors
        for (int i = 0; i < 14; i = i + 1) begin
            // Apply inputs
            A = A_values[i];
            B = B_values[i];
            
            // Assert valid for one cycle
            @(negedge clk_n);
            valid_i = 1'b1;
            @(negedge clk_n);
            valid_i = 1'b0;
            
            // Wait for done signal
            wait(done_o);

            @(negedge clk_n);
        end
        #10 $finish;
    end
    
endmodule
