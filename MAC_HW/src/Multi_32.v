`timescale 1ns / 100ps

module multiply_32 #(
    parameter WIDTH = 32
) (
    input [WIDTH - 1:0] A,
    input [WIDTH - 1:0] B,
    input clk_n,
    input rst_n,
    output Sign,
    output [WIDTH - 25:0] Exponent,
    output [WIDTH - 10:0] Mantissa
);

  wire [WIDTH - 9:0] A_Mantissa_w_i, B_Mantissa_w_i;
  wire [WIDTH - 25:0] A_Exponent_w_i, B_Exponent_w_i;
  
  wire [WIDTH - 9:0] A_Mantissa_w_o, B_Mantissa_w_o;
  wire [WIDTH - 25:0] A_Exponent_w_o, B_Exponent_w_o;
  
  wire [47:0] Temp_Mantissa;
  wire [WIDTH - 25:0] Temp_Exponent;

  register #(WIDTH - 24) A_Exponent_reg (
        .clk_n(clk_n),
        .rst_n(rst_n),
        .LD(1'b1),
        .datain(A_Exponent_w_i),
        .out(A_Exponent_w_o)
    );

  register #(WIDTH - 24) B_Exponent_reg (
      .clk_n(clk_n),
      .rst_n(rst_n),
      .LD(1'b1),
      .datain(B_Exponent_w_i),
      .out(B_Exponent_w_o)
  );

  register #(WIDTH - 8) A_Mantissa_reg (
      .clk_n(clk_n),
      .rst_n(rst_n),
      .LD(1'b1),
      .datain(A_Mantissa_w_i),
      .out(A_Mantissa_w_o)
  );

  register #(WIDTH - 8) B_Mantissa_reg (
      .clk_n(clk_n),
      .rst_n(rst_n),
      .LD(1'b1),
      .datain(B_Mantissa_w_i),
      .out(B_Mantissa_w_o)
  );

  assign A_Mantissa_w_i = {1'b1, A[WIDTH - 10:0]};
  assign A_Exponent_w_i = A[WIDTH - 2:WIDTH - 9];

  assign B_Mantissa_w_i = {1'b1, B[WIDTH - 10:0]};
  assign B_Exponent_w_i = B[WIDTH - 2:WIDTH - 9];

  assign Temp_Exponent = A_Exponent_w_o + B_Exponent_w_o - 127;
  assign Temp_Mantissa = A_Mantissa_w_o * B_Mantissa_w_o;
    
  assign Sign = A[WIDTH - 1] ^ B[WIDTH - 1];
  assign Exponent = (A[22:0] == 0 | B[22:0] == 0) ? 'b0 : Temp_Mantissa[47] ? Temp_Exponent + 1'b1 : Temp_Exponent;
  assign Mantissa = (A[22:0] == 0 | B[22:0] == 0) ? 'b0 : Temp_Mantissa[47] ? Temp_Mantissa[46:24] : Temp_Mantissa[45:23];

endmodule