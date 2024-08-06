`timescale 1ns / 1ps

module r4booth_even #(
  parameter N = 12
)(
  input clk, input rst,
  input [N-1:0] multiplicand,
  input [N-1:0] multiplier,
  output reg [(2*N)-1:0] product
);

  reg [2*N-1:0] partial_product[0:N/2];
  reg [2*N-1:0] partial_product_hold[0:N/2];

  reg [2:0] mul_mod[0:N/2];
  wire [N+2:0] __multiplier_;
  wire [N:0] _multiplicand;
  
  reg [2*N-1:0] val[0:N/4-1];
  reg [2*N-1:0] val_next[0:N/4-1];
  
  reg [N-1:0] multiplicand_hold;
  reg [N-1:0] multiplier_hold;
  
  reg [2*N-1:0] partial_product_last;
  reg  [(2*N)-1:0] accum;
  
  integer i;
  
  always @(negedge clk or negedge rst) begin
    if (~rst) begin
      multiplicand_hold <= 'b0;
      multiplier_hold <= 'b0;
    end else begin
      multiplicand_hold <= multiplicand;
      multiplier_hold <= multiplier;
    end
  end

  assign __multiplier_ = {1'b0, 1'b0, multiplier_hold, 1'b0};
  assign _multiplicand = {1'b0, multiplicand_hold};
  
  always @(*) begin
    mul_mod[0] = __multiplier_[2:0];
    mul_mod[1] = __multiplier_[4:2];
    mul_mod[2] = __multiplier_[6:4];
    mul_mod[3] = __multiplier_[8:6];
    mul_mod[4] = __multiplier_[10:8];
    mul_mod[5] = __multiplier_[12:10];
    mul_mod[6] = __multiplier_[14:12];
//    mul_mod[7] = __multiplier_[16:14];
//    mul_mod[8] = __multiplier_[18:16];
//    mul_mod[9] = __multiplier_[20:18];
//    mul_mod[10] = __multiplier_[22:20];
//    mul_mod[11] = __multiplier_[24:22];
//    mul_mod[12] = __multiplier_[26:24];
    
    for (i = 0; i < N/2+1; i = i + 1) begin
      case(mul_mod[i])
        3'b000: partial_product[i] = 'b0;
        3'b001: partial_product[i] = _multiplicand;
        3'b010: partial_product[i] = _multiplicand;
        3'b011: partial_product[i] = _multiplicand << 1;
        3'b100: partial_product[i] = ~(_multiplicand << 1) + 1'b1;
        3'b101: partial_product[i] = ~_multiplicand + 1'b1;
        3'b110: partial_product[i] = ~_multiplicand + 1'b1;
        3'b111: partial_product[i] = 'b0;
      endcase
    end
  end
  
  always @(negedge clk or negedge rst) begin
    if (~rst)
      for (i = 0; i < N/2 + 1; i = i + 1)
        partial_product_hold[i] <= 'b0;

    else
      for (i = 0; i < N/2 + 1; i = i + 1)
        partial_product_hold[i] <= partial_product[i];
  end

  always @(*)
      for (i = 0; i < N/4; i = i + 1) 
        val[i] = partial_product_hold[2*i] + (partial_product_hold[2*i+1] << 2);

  always @(negedge clk or negedge rst) begin
    if (~rst)
      for (i = 0; i < N/4; i = i + 1)
        val_next[i] <= 'b0;
        
    else
      for (i = 0; i < N/4; i = i + 1)
        val_next[i] <= val[i];
  end
  
  always @(negedge clk or negedge rst) begin
    if (~rst) partial_product_last <= 'b0;
    else partial_product_last <= partial_product_hold[N/2] << N;
  end

  always @(*) begin
    accum = partial_product_last;
    for (i = 0; i < N/4; i = i + 1) 
      accum = accum + (val_next[i] << (4 * i));
  end

  always @(negedge clk or negedge rst) begin
    if (~rst) product <= 'b0;
    else product <= accum;
  end
  
//  always @(*) begin
//    product = 'b0;
//      for (i = 0; i < N/2+1; i = i + 1)
//        product = product + (partial_product_hold[i] << (2 * i));
//  end

endmodule
