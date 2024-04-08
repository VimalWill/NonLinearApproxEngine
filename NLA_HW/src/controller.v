`timescale 1ns / 100ps

module controller #(
    parameter ADDR_LINES = 4
) (
    input clk,
    input rst_n,
    
    input [3:0] wr_ptr_coeff,
    input start_signal,
    input start_coeff,
    
    input mode,
    input signal_sign,
    
    output reg rst_reg_n,
                   
    output reg wr_en_signal,
    output reg wr_en_coeff,
    output reg rd_en_signal,
    output reg rd_en_coeff,
                   
    output reg LD_signal,
    output reg LD_coeff,
    
    output reg LD_direct,
    output reg LD_rawResult,
    output reg LD_final,
    
    output reg LD_result,
    
    output reg redo
);
    
    reg [2:0] state, next_state;
    reg [3:0] count;
    
    localparam S0 = 3'b000;
    localparam S1 = 3'b001;
    localparam S2 = 3'b010;
    localparam S3 = 3'b011;
    localparam S4 = 3'b100;
    localparam S5 = 3'b101;
    localparam S6 = 3'b110;
    localparam S7 = 3'b111;
    
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            rst_reg_n <= 1'b0;
            state <= S0;
        end else begin
            rst_reg_n <= 1'b1;
            state <= next_state;
        end
    end
    
    always @(*) begin
        
        wr_en_signal = 1'b0;
        wr_en_coeff = 1'b0;
        rd_en_signal = 1'b0;
        rd_en_coeff = 1'b0;
        
        LD_signal = 1'b0;
        LD_coeff = 1'b0;
        
        LD_direct = 1'b0;
        LD_rawResult = 1'b0;
        LD_final = 1'b0;
        
        LD_result = 1'b0;
        
        redo = 1'b0;
        next_state = 'b0;
        
        case(state) 
            S0: begin // Load Buffers
            
                if(start_signal & start_coeff) begin
    
                    rd_en_signal = 1'b1;
                    redo = 1'b1;
                    count = wr_ptr_coeff;
                    
                    next_state = S1;
                end else begin
                    
                    if(!start_signal)
                        wr_en_signal = 1'b1;
                        
                    else if(!start_coeff)
                        wr_en_coeff = 1'b1;
                        
                    next_state = S0;
                end 
            end
            
            S1: begin // Pull from Adder Buffer
                if (~(mode | signal_sign)) begin// NOR
                    LD_direct = 1'b1;
                    next_state = S7;
                end
                else begin
                    LD_coeff = 1'b1;
                    next_state = S2;
                end
            end
            
            S2: begin // Addition
                next_state = S3;
            end 
            
            S3: begin // Pull from Multiplier Buffer
                LD_signal = 1'b1;
                next_state = S4;
            end
            
            S4: begin // Multiplication and Check
            
                if(count == 0) begin
                    LD_rawResult = mode ? 1'b0 : 1'b1;
                    next_state = signal_sign ? S6 : S7;
                end else  
                    next_state = S5;
            end
            
            S5: begin // Decrement counter
                rd_en_coeff = 1'b1;
                count = count - 1;
                next_state = S1;
            end
            
            S6: begin
            
                LD_final = 1'b1;
                next_state = S7;
            
            end
            
            S7: begin
            
                LD_result = 1'b1;
                next_state = S0;
            
            end
         endcase
     end
endmodule