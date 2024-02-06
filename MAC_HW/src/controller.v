`timescale 1ns / 100ps

module controller( input clk,
                   input rst_n,
                   input full,
                   input empty,
                   output reg rst_reg_n,
                   output reg LD_signal,
                   output reg LD_coeff,
                   output reg push);
    
    reg [1:0] state, next_state;
    
    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;
    localparam S3 = 2'b11;
    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            rst_reg_n <= 1'b0;
            state <= S0;
        end else begin
                rst_reg_n <= 1;
                state <= next_state;
        end
    end
    
    always @* begin
    
        LD_signal = 1'b0;
        LD_coeff = 1'b0;
        push = 1'b0;
        next_state = 'b0;
        
        case(state) 
            S0: begin //Idle_state
                LD_signal = 1'b0;
                LD_coeff = 1'b0;
                
                if(full) begin
                    push = 1'b0;
                    next_state = S1;
                end else begin
                    push = 1'b1;
                    next_state = S0;
                end 
            end
            
            S1: begin //Adder_pipe   
                LD_signal = 1'b0;
                LD_coeff = 1'b1;
                
                next_state = S2;
            end 
            
            S2: begin //Multiply_pipe        
                LD_signal = 1'b1;
                LD_coeff = 1'b0;        
                
                next_state = S3;
            end 
            
            S3: begin //Check FIFO flags
                if(empty)
                    next_state = S0;
                else
                    next_state = S1;
            end
            
         endcase
     end
endmodule